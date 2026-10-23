//! The lowering: a checked program becomes Mojo source, the way the OpenCL
//! emitter in X_eTaL-gpu writes OpenCL C. Each run of elementwise values
//! between reductions is one fused kernel (one thread per element, the
//! intermediate values in registers); each reduction is a two-pass
//! shared-memory tree on the device; the host side moves the arrays and
//! exports a fixed C ABI that the Rust tool calls through `dlopen`.
//!
//! The generated file is meant to read like a Mojo programmer's: compare it
//! with `max/examples/gpu-functions/vector_addition.mojo` and
//! `reduction.mojo` in this repository.

use crate::ir::{MapOp, Op, Program, RedOp, Ty};
use std::collections::BTreeSet;
use std::fmt::Write;

pub const TPB: usize = 256;

#[derive(Clone, Debug)]
pub enum Step {
    /// One fused elementwise kernel computing these values, in order.
    Kernel(Vec<usize>),
    /// A reduction of this value's source into its one-element buffer.
    Reduce(usize),
}

#[derive(Clone, Debug)]
pub struct Plan {
    pub steps: Vec<Step>,
    /// Which values live in a device buffer (the rest stay in registers or
    /// are literals in the kernel text).
    pub materialized: Vec<bool>,
    /// For map and select values: the index of the kernel step that computes them.
    pub stage_of: Vec<Option<usize>>,
}

impl Plan {
    pub fn kernels(&self) -> usize {
        self.steps.iter().filter(|s| matches!(s, Step::Kernel(_))).count()
    }
    pub fn reductions(&self) -> usize {
        self.steps.iter().filter(|s| matches!(s, Step::Reduce(_))).count()
    }
    /// The kernel stage a map or select value is computed in.
    pub fn stage(&self, value: usize) -> Option<usize> {
        self.stage_of[value]
    }
    pub fn buffers(&self) -> usize {
        self.materialized.iter().filter(|&&m| m).count()
    }
}

fn is_elementwise(op: &Op) -> bool {
    matches!(op, Op::Map(..) | Op::Select(..) | Op::Cast(..))
}

fn args_of(op: &Op) -> Vec<usize> {
    match op {
        Op::Map(_, a) => a.clone(),
        Op::Select(c, a, b) => vec![*c, *a, *b],
        Op::Cast(a) | Op::Reduce(_, a) => vec![*a],
        _ => vec![],
    }
}

/// A scalar constant is a literal in kernel text, never a buffer (unless it
/// is itself an output).
fn is_literal(p: &Program, i: usize) -> bool {
    matches!(&p.values[i].op, Op::Const(items) if items.len() == 1 && !p.values[i].is_vector())
}

pub fn plan(p: &Program) -> Plan {
    let count = p.values.len();
    let mut steps = Vec::new();
    let mut stage_of = vec![None; count];
    let mut current: Vec<usize> = Vec::new();
    let mut kernel_index = 0usize;
    for (i, v) in p.values.iter().enumerate() {
        match &v.op {
            Op::Map(..) | Op::Select(..) | Op::Cast(..) => {
                stage_of[i] = Some(kernel_index);
                current.push(i);
            }
            Op::Reduce(..) => {
                if !current.is_empty() {
                    steps.push(Step::Kernel(std::mem::take(&mut current)));
                    kernel_index += 1;
                }
                steps.push(Step::Reduce(i));
            }
            _ => {}
        }
    }
    if !current.is_empty() {
        steps.push(Step::Kernel(current));
    }

    let mut materialized = vec![false; count];
    for (i, v) in p.values.iter().enumerate() {
        match &v.op {
            Op::Input | Op::Reduce(..) => materialized[i] = true,
            Op::Const(_) => materialized[i] = !is_literal(p, i),
            _ => {}
        }
    }
    for &o in &p.outputs {
        materialized[o] = true;
    }
    for (i, v) in p.values.iter().enumerate() {
        for a in args_of(&v.op) {
            let crosses = match (&v.op, stage_of[a]) {
                (Op::Reduce(..), _) => true,
                (_, Some(s)) => stage_of[i] != Some(s),
                _ => false,
            };
            if crosses && is_elementwise(&p.values[a].op) {
                materialized[a] = true;
            }
        }
    }
    Plan { steps, materialized, stage_of }
}

fn lit(x: f32) -> String {
    if x.is_finite() {
        format!("Float32({:?})", x)
    } else if x.is_nan() {
        "Float32(nan[DType.float32]())".to_string()
    } else if x > 0.0 {
        "Float32(inf[DType.float32]())".to_string()
    } else {
        "Float32(-inf[DType.float32]())".to_string()
    }
}

fn expr(p: &Program, i: usize) -> String {
    let v = |a: usize| -> String {
        if is_literal(p, a) {
            if let Op::Const(items) = &p.values[a].op {
                return if p.values[a].ty == Ty::Bool {
                    (if items[0] != 0.0 { "True" } else { "False" }).to_string()
                } else {
                    lit(items[0])
                };
            }
        }
        format!("v_{}", p.values[a].name)
    };
    match &p.values[i].op {
        Op::Map(op, a) => {
            use MapOp::*;
            let x = v(a[0]);
            let y = a.get(1).map(|&b| v(b)).unwrap_or_default();
            match op {
                Add => format!("{x} + {y}"),
                Sub => format!("{x} - {y}"),
                Mul => format!("{x} * {y}"),
                Div => format!("{x} / {y}"),
                // Floored, as X_eTaL's: Mojo's Int `%` is Python's; for
                // floats the formula says so.
                Mod => {
                    if p.values[i].ty == Ty::I64 {
                        format!("Float32(Int({x}) % Int({y}))")
                    } else {
                        format!("{x} - {y} * floor({x} / {y})")
                    }
                }
                Min => format!("min({x}, {y})"),
                Max => format!("max({x}, {y})"),
                Neg => format!("-{x}"),
                Abs => format!("abs({x})"),
                Exp => format!("exp({x})"),
                Log => format!("log({x})"),
                Eq => format!("Bool({x} == {y})"),
                Ne => format!("Bool({x} != {y})"),
                Lt => format!("Bool({x} < {y})"),
                Le => format!("Bool({x} <= {y})"),
                Gt => format!("Bool({x} > {y})"),
                Ge => format!("Bool({x} >= {y})"),
                And => format!("{x} and {y}"),
                Or => format!("{x} or {y}"),
                Not => format!("not {x}"),
            }
        }
        Op::Select(c, a, b) => format!("{} if {} else {}", v(*a), v(*c), v(*b)),
        Op::Cast(a) => {
            let x = v(*a);
            match (p.values[*a].ty, p.values[i].ty) {
                (Ty::Bool, Ty::Bool) => x,
                (Ty::Bool, _) => format!("Float32(1.0) if {x} else Float32(0.0)"),
                (_, Ty::Bool) => format!("Bool({x} != 0.0)"),
                (Ty::F32, Ty::I64) => format!("Float32(Int({x}))"),
                _ => x,
            }
        }
        _ => unreachable!("only elementwise values have expressions"),
    }
}

/// The identity (in terms of `src`) and the combine of `lhs` and `rhs`.
fn reduce_parts(op: RedOp) -> (&'static str, &'static str) {
    match op {
        RedOp::Add => ("Float32(0.0)", "lhs + rhs"),
        RedOp::Max => ("src[unsafe_offset=0]", "max(lhs, rhs)"),
        RedOp::Min => ("src[unsafe_offset=0]", "min(lhs, rhs)"),
    }
}

fn reduce_kernel(op: RedOp) -> String {
    let (identity, combine) = reduce_parts(op);
    format!(
        r#"
def reduce_{name}(
    src: Pointer[Float32, ImmutAnyOrigin],
    dst: Pointer[Float32, MutAnyOrigin],
    n: Int32,
):
    """One block reduces TPB items of src into dst[block]: a tree in shared memory."""
    var shared = unsafe_stack_allocation[TPB, Float32, address_space=.SHARED]()
    var tid = Int(thread_idx.x)
    var i = Int(block_idx.x) * TPB + tid
    var v: Float32 = {identity}
    if i < Int(n):
        v = src[unsafe_offset=i]
    shared[unsafe_offset=tid] = v
    barrier()
    var active = TPB // 2
    while active > 0:
        if tid < active:
            var lhs = shared[unsafe_offset=tid]
            var rhs = shared[unsafe_offset=tid + active]
            shared[unsafe_offset=tid] = {combine}
        barrier()
        active //= 2
    if tid == 0:
        dst[unsafe_offset=Int(block_idx.x)] = shared[unsafe_offset=0][0]
"#,
        name = op.name(),
        identity = identity,
        combine = combine
    )
}

fn stage_kernel(p: &Program, plan: &Plan, k: usize, vals: &[usize]) -> String {
    let inside: BTreeSet<usize> = vals.iter().copied().collect();
    let mut reads: BTreeSet<usize> = BTreeSet::new();
    for &i in vals {
        for a in args_of(&p.values[i].op) {
            if !inside.contains(&a) && !is_literal(p, a) {
                reads.insert(a);
            }
        }
    }
    let writes: Vec<usize> = vals.iter().copied().filter(|&i| plan.materialized[i]).collect();
    let mut params = String::new();
    for &r in &reads {
        let _ = writeln!(params, "    b_{}: Pointer[Float32, ImmutAnyOrigin],", p.values[r].name);
    }
    for &w in &writes {
        let _ = writeln!(params, "    b_{}: Pointer[Float32, MutAnyOrigin],", p.values[w].name);
    }
    let args: Vec<String> = reads.iter().chain(writes.iter()).map(|&i| format!("b_{}", p.values[i].name)).collect();
    let names: Vec<String> = vals.iter().map(|&i| format!("%{}", p.values[i].name)).collect();

    // The body, for element i: shared by the GPU kernel and the CPU range.
    let mut s = String::new();
    let _ = writeln!(s, "\n@inline(.always)\ndef stage{k}_at(\n    i: Int,\n{params}):");
    let _ = writeln!(s, "    \"\"\"Stage {k}, element i: {} fused.\"\"\"", names.join(", "));
    for &r in &reads {
        let v = &p.values[r];
        let idx = if v.is_vector() { "i" } else { "0" };
        let load = if v.ty == Ty::Bool {
            format!("Bool(b_{}[unsafe_offset={idx}] != 0.0)", v.name)
        } else {
            format!("b_{}[unsafe_offset={idx}]", v.name)
        };
        let _ = writeln!(s, "    var v_{} = {}", v.name, load);
    }
    for &i in vals {
        let _ = writeln!(s, "    var v_{} = {}", p.values[i].name, expr(p, i));
    }
    for &w in &writes {
        let v = &p.values[w];
        let stored = if v.ty == Ty::Bool {
            format!("Float32(1.0) if v_{} else Float32(0.0)", v.name)
        } else {
            format!("v_{}", v.name)
        };
        if v.is_vector() {
            let _ = writeln!(s, "    b_{}[unsafe_offset=i] = {}", v.name, stored);
        } else {
            let _ = writeln!(s, "    if i == 0:\n        b_{}[unsafe_offset=0] = {}", v.name, stored);
        }
    }

    // The kernel: one thread per element.
    let _ = writeln!(s, "\n\ndef stage{k}(\n{params}    n: Int32,\n):");
    let _ = writeln!(s, "    \"\"\"Stage {k}: {} fused, one thread per element.\"\"\"", names.join(", "));
    let _ = writeln!(s, "    var i = Int(block_idx.x * block_dim.x + thread_idx.x)");
    let _ = writeln!(s, "    if i < Int(n):");
    let _ = writeln!(s, "        stage{k}_at(i, {})", args.join(", "));
    s
}

/// Emit a standalone CPU expression check using the same Mojo stage emitter.
/// The exported stage retains dynamic pointer arguments for readable assembly.
pub fn emit_cpu(p: &Program, inputs: &std::collections::HashMap<String, Vec<f32>>, expected: &[Vec<f32>]) -> Result<String, String> {
    if expected.len() != p.outputs.len() || expected.iter().zip(&p.outputs).any(|(xs, &i)| xs.len() != p.values[i].len()) {
        return Err("Mojo CPU oracle shape mismatch".into());
    }
    let plan = plan(p);
    if plan.reductions() != 0 || plan.kernels() != 1 || p.outputs.iter().any(|&i| !is_elementwise(&p.values[i].op)) {
        return Err("Mojo CPU comparison supports one elementwise stage and computed outputs".into());
    }
    let Step::Kernel(vals) = &plan.steps[0] else { unreachable!() };
    let inside: BTreeSet<usize> = vals.iter().copied().collect();
    let reads: BTreeSet<usize> = vals.iter().flat_map(|&i| args_of(&p.values[i].op)).filter(|i| !inside.contains(i) && !is_literal(p, *i)).collect();
    let writes: Vec<usize> = vals.iter().copied().filter(|&i| plan.materialized[i]).collect();
    let mut s = String::from("# Generated by xir-mojo emit-cpu; same stage expressions as the GPU emitter.\nfrom std.math import exp, log, floor, inf, nan\nfrom std.collections import List\n");
    let kernel = stage_kernel(p, &plan, 0, vals)
        .replacen("def stage0(", "@export(\"xir_cpu_stage0\")\ndef stage0(", 1)
        .replacen("    n: Int32,\n):", "    n: Int32,\n    element_index: Int,\n) abi(\"C\"):", 1)
        .replace("var i = Int(block_idx.x * block_dim.x + thread_idx.x)", "var i = element_index")
        .replace("fused, one thread per element", "fused, one CPU call per element");
    s.push_str(&kernel);
    s.push_str("\ndef main() raises:\n");
    for &i in &reads {
        let v = &p.values[i];
        let data = match &v.op {
            Op::Input => inputs.get(&v.name).ok_or_else(|| format!("unbound input %{}", v.name))?.clone(),
            Op::Const(xs) => if xs.len() == 1 { vec![xs[0]; v.len()] } else { xs.clone() },
            _ => unreachable!(),
        };
        if data.len() != v.len() { return Err("Mojo CPU input shape mismatch".into()); }
        writeln!(s, "    var h_{}: List[Float32] = [{}]", v.name, data.iter().map(|&x| lit(x)).collect::<Vec<_>>().join(", ")).unwrap();
    }
    for &i in &writes {
        writeln!(s, "    var h_{} = List[Float32](length={}, fill=Float32(0.0))", p.values[i].name, p.values[i].len()).unwrap();
    }
    let args: Vec<String> = reads.iter().chain(&writes).map(|&i| format!("h_{}.unsafe_ptr(){}", p.values[i].name, if reads.contains(&i) { ".as_imm().as_unsafe_any_origin()" } else { ".as_unsafe_any_origin()" })).collect();
    writeln!(s, "    for i in range({}):\n        stage0({}, Int32({}), i)\n    var failures = 0", p.n, args.join(", "), p.n).unwrap();
    for (j, &o) in p.outputs.iter().enumerate() {
        let v = &p.values[o];
        writeln!(s, "    var expected_{j}: List[Float32] = [{}]\n    print(\"output %{}:\", h_{})\n    for i in range({}):\n        var got = h_{}[i]\n        var want = expected_{j}[i]", expected[j].iter().map(|&x| lit(x)).collect::<Vec<_>>().join(", "), v.name, v.name, v.len(), v.name).unwrap();
        let condition = if v.ty == Ty::F32 { "not (abs(got - want) <= max(Float32(1e-6), abs(want) * Float32(1e-4)))" } else { "got != want" };
        writeln!(s, "        if {condition}:\n            failures += 1").unwrap();
    }
    s.push_str("    print(\"backend: Mojo CPU\")\n    print(\"RESULT:\", failures, \"mismatched elements\")\n    if failures != 0:\n        raise Error(\"CPU outputs disagree with oracle\")\n");
    Ok(s)
}

/// The Mojo source for the program, specialized to its length N.
pub fn emit(p: &Program, plan: &Plan, name: &str) -> String {
    let mut s = String::new();
    let _ = writeln!(
        s,
        "# {name}.mojo: generated by xir-mojo (Rust) from {name}.xir. Do not edit.\n\
         # N = {n} elements, {k} fused kernel stage(s), {r} reduction(s), {b} device buffer(s).",
        name = name,
        n = p.n,
        k = plan.kernels(),
        r = plan.reductions(),
        b = plan.buffers()
    );
    let ints: Vec<String> = p
        .values
        .iter()
        .filter(|v| v.ty == Ty::I64)
        .map(|v| format!("%{}", v.name))
        .collect();
    if !ints.is_empty() {
        let _ = writeln!(
            s,
            "# i64 in the IR, carried as Float32 on the device (exact below 2^24): {}.",
            ints.join(", ")
        );
    }
    s.push_str(
        r#"
from std.math import exp, log, floor, inf, nan
from std.memory import unsafe_stack_allocation
from std.runtime import initialize_runtime
from std.sys import get_defined_bool, has_accelerator

from max.gpu import block_dim, block_idx, thread_idx
from max.gpu.host import DeviceContext
from max.gpu.sync import barrier

# Built with `-D XIR_CPU=true`, the same program runs on the CPU: the same
# DeviceContext calls against a CPU context, each stage as a parallel range
# over the elements (enqueue_cpu_range) instead of a grid, each reduction a
# plain fold. Nothing else changes.
comptime XIR_CPU = get_defined_bool["XIR_CPU"]()
"#,
    );
    let _ = writeln!(s, "\ncomptime N = {}", p.n);
    let _ = writeln!(s, "comptime TPB = {}", TPB);
    let _ = writeln!(s, "comptime BLOCKS = (N + TPB - 1) // TPB");

    let mut red_ops: Vec<RedOp> = Vec::new();
    for v in &p.values {
        if let Op::Reduce(op, _) = v.op {
            if !red_ops.contains(&op) {
                red_ops.push(op);
            }
        }
    }
    for op in &red_ops {
        s.push_str(&reduce_kernel(*op));
    }
    for (k, step) in plan.steps.iter().enumerate() {
        if let Step::Kernel(vals) = step {
            let stage_no = plan.steps[..k].iter().filter(|x| matches!(x, Step::Kernel(_))).count();
            s.push_str(&stage_kernel(p, plan, stage_no, vals));
        }
    }

    s.push_str(
        r#"

def xir_context() raises -> DeviceContext:
    """The device the program runs on: the GPU, or the CPU when built with -D XIR_CPU=true."""
    comptime if XIR_CPU:
        return DeviceContext(api="cpu")
    else:
        return DeviceContext()


def trace(
    block_of: Pointer[Int32, MutAnyOrigin],
    thread_of: Pointer[Int32, MutAnyOrigin],
    n: Int32,
):
    """Provenance: which block and thread computed each element."""
    var i = Int(block_idx.x * block_dim.x + thread_idx.x)
    if i < Int(n):
        block_of[unsafe_offset=i] = Int32(block_idx.x)
        thread_of[unsafe_offset=i] = Int32(thread_idx.x)


@export("xir_init")
def xir_init() abi("C") -> Int32:
    """Initializes the Mojo runtime; 1 when this build targets a GPU, else 0."""
    initialize_runtime()
    comptime if has_accelerator():
        return 1
    else:
        return 0


@export("xir_device_info")
def xir_device_info(buf: Pointer[UInt8, MutAnyOrigin], cap: Int64) abi("C") -> Int64:
    """Writes `api=...;name=...` for the device the kernels run on; its length, or -1."""
    initialize_runtime()
    try:
        var ctx = xir_context()
        var s = String("api=", ctx.api(), ";name=", ctx.name())
        var bytes = s.as_bytes()
        var n = min(len(bytes), Int(cap))
        for i in range(n):
            buf[unsafe_offset=i] = bytes[i]
        return Int64(n)
    except e:
        return -1


@export("xir_launch")
def xir_launch(blocks: Pointer[Int32, MutAnyOrigin], tpb: Pointer[Int32, MutAnyOrigin]) abi("C") -> Int32:
    """The launch geometry every elementwise kernel here uses."""
    blocks[unsafe_offset=0] = Int32(BLOCKS)
    tpb[unsafe_offset=0] = Int32(TPB)
    return 0


@export("xir_trace")
def xir_trace(
    block_of: Pointer[Int32, MutAnyOrigin],
    thread_of: Pointer[Int32, MutAnyOrigin],
    n: Int64,
) abi("C") -> Int32:
    """Runs the provenance kernel: block_of[i], thread_of[i] for each of N elements; 3 on the CPU (no grid)."""
    initialize_runtime()
    if Int(n) != N:
        return 2
    comptime if XIR_CPU:
        return 3
    try:
        var ctx = xir_context()
        var b_dev = ctx.enqueue_create_buffer[DType.int32](N)
        var t_dev = ctx.enqueue_create_buffer[DType.int32](N)
        ctx.enqueue_function[trace](b_dev, t_dev, Int32(N), grid_dim=BLOCKS, block_dim=TPB)
        var b_host = ctx.enqueue_create_host_buffer[DType.int32](N)
        var t_host = ctx.enqueue_create_host_buffer[DType.int32](N)
        ctx.enqueue_copy(dst_buf=b_host, src_buf=b_dev)
        ctx.enqueue_copy(dst_buf=t_host, src_buf=t_dev)
        ctx.synchronize()
        for i in range(N):
            block_of[unsafe_offset=i] = b_host[i]
            thread_of[unsafe_offset=i] = t_host[i]
        return 0
    except e:
        print("xir_trace failed:", e)
        return 1


@export("xir_run")
def xir_run(
    inputs: Pointer[Pointer[Float32, ImmutAnyOrigin], ImmutAnyOrigin],
    outputs: Pointer[Pointer[Float32, MutAnyOrigin], ImmutAnyOrigin],
    n: Int64,
) abi("C") -> Int32:
    """Runs the program: inputs[k] in program order, outputs[j] in output order.

    Returns 0 when done, 2 when n is not this build's N, 1 when the device failed.
    """
    initialize_runtime()
    if Int(n) != N:
        return 2
    try:
        var ctx = xir_context()
"#,
    );

    // Host buffers for inputs and vector constants, then one synchronize, then fills.
    let inputs = p.inputs();
    let mut host_lines = Vec::new();
    let mut fill_lines = Vec::new();
    for (k, &i) in inputs.iter().enumerate() {
        let v = &p.values[i];
        host_lines.push(format!(
            "        var h_{} = ctx.enqueue_create_host_buffer[DType.float32]({})",
            v.name,
            v.len()
        ));
        fill_lines.push(format!(
            "        for i in range({}):\n            h_{}[i] = inputs[unsafe_offset={}][unsafe_offset=i]",
            v.len(),
            v.name,
            k
        ));
    }
    for (i, v) in p.values.iter().enumerate() {
        if let Op::Const(items) = &v.op {
            if plan.materialized[i] && items.len() > 1 {
                host_lines.push(format!(
                    "        var h_{} = ctx.enqueue_create_host_buffer[DType.float32]({})",
                    v.name,
                    v.len()
                ));
                for (j, x) in items.iter().enumerate() {
                    fill_lines.push(format!("        h_{}[{}] = {}", v.name, j, lit(*x)));
                }
            }
        }
    }
    for l in &host_lines {
        let _ = writeln!(s, "{l}");
    }
    if !host_lines.is_empty() {
        let _ = writeln!(s, "        ctx.synchronize()");
    }
    for l in &fill_lines {
        let _ = writeln!(s, "{l}");
    }

    // Device buffers.
    let _ = writeln!(s, "        # device buffers, one per materialized value");
    for (i, v) in p.values.iter().enumerate() {
        if !plan.materialized[i] {
            continue;
        }
        let _ = writeln!(
            s,
            "        var b_{} = ctx.enqueue_create_buffer[DType.float32]({})",
            v.name,
            v.len()
        );
        match &v.op {
            Op::Input => {
                let _ = writeln!(s, "        ctx.enqueue_copy(dst_buf=b_{0}, src_buf=h_{0})", v.name);
            }
            Op::Const(items) => {
                if items.len() == 1 {
                    let _ = writeln!(s, "        b_{}.enqueue_fill({})", v.name, lit(items[0]));
                } else {
                    let _ = writeln!(s, "        ctx.enqueue_copy(dst_buf=b_{0}, src_buf=h_{0})", v.name);
                }
            }
            Op::Reduce(..) => {
                let _ = writeln!(
                    s,
                    "        var b_{}_partial = ctx.enqueue_create_buffer[DType.float32](BLOCKS)",
                    v.name
                );
            }
            _ => {}
        }
    }

    // The steps.
    let mut stage_no = 0usize;
    for step in &plan.steps {
        match step {
            Step::Kernel(vals) => {
                let inside: BTreeSet<usize> = vals.iter().copied().collect();
                let mut reads: BTreeSet<usize> = BTreeSet::new();
                for &i in vals {
                    for a in args_of(&p.values[i].op) {
                        if !inside.contains(&a) && !is_literal(p, a) {
                            reads.insert(a);
                        }
                    }
                }
                let writes: Vec<usize> =
                    vals.iter().copied().filter(|&i| plan.materialized[i]).collect();
                let mut args: Vec<String> = Vec::new();
                for &r in &reads {
                    args.push(format!("b_{}", p.values[r].name));
                }
                for &w in &writes {
                    args.push(format!("b_{}", p.values[w].name));
                }
                let _ = writeln!(s, "        # stage {stage_no}\n        comptime if XIR_CPU:\n            ctx.synchronize()");
                let mut ptrs: Vec<String> = Vec::new();
                for &r in &reads {
                    let name = &p.values[r].name;
                    let _ = writeln!(
                        s,
                        "            var p{stage_no}_{name} = b_{name}.unsafe_ptr().as_imm().unsafe_origin_cast[ImmutAnyOrigin]()"
                    );
                    ptrs.push(format!("p{stage_no}_{name}"));
                }
                for &w in &writes {
                    let name = &p.values[w].name;
                    let _ = writeln!(s, "            var p{stage_no}_{name} = b_{name}.unsafe_ptr().unsafe_origin_cast[MutAnyOrigin]()");
                    ptrs.push(format!("p{stage_no}_{name}"));
                }
                let _ = writeln!(
                    s,
                    "            def stage{stage_no}_body(i: Int) {{imm}}:\n                stage{stage_no}_at(i, {})\n            \
                     ctx.enqueue_cpu_range(stage{stage_no}_body, N)\n        else:",
                    ptrs.join(", ")
                );
                args.push("Int32(N)".to_string());
                let _ = writeln!(
                    s,
                    "            ctx.enqueue_function[stage{stage_no}]({}, grid_dim=BLOCKS, block_dim=TPB)",
                    args.join(", ")
                );
                stage_no += 1;
            }
            Step::Reduce(i) => {
                if let Op::Reduce(op, a) = &p.values[*i].op {
                    let name = &p.values[*i].name;
                    let src = &p.values[*a].name;
                    let (identity, combine) = reduce_parts(*op);
                    let _ = writeln!(
                        s,
                        "        # reduce {op} %{src} -> %{name}: a partial per block, then one block over the partials (a fold on the CPU)\n        \
                         comptime if XIR_CPU:\n            \
                         ctx.synchronize()\n            \
                         var src = b_{src}.unsafe_ptr().as_imm().unsafe_origin_cast[ImmutAnyOrigin]()\n            \
                         var dst = b_{name}.unsafe_ptr().unsafe_origin_cast[MutAnyOrigin]()\n            \
                         var acc: Float32 = {identity}\n            \
                         for i in range(N):\n                \
                         var lhs = acc\n                \
                         var rhs = src[unsafe_offset=i]\n                \
                         acc = {combine}\n            \
                         dst[unsafe_offset=0] = acc\n        \
                         else:\n            \
                         ctx.enqueue_function[reduce_{op}](b_{src}, b_{name}_partial, Int32(N), grid_dim=BLOCKS, block_dim=TPB)\n            \
                         ctx.enqueue_function[reduce_{op}](b_{name}_partial, b_{name}, Int32(BLOCKS), grid_dim=1, block_dim=TPB)",
                        op = op.name(),
                        src = src,
                        name = name,
                        identity = identity,
                        combine = combine
                    );
                }
            }
        }
    }

    // Outputs back.
    let _ = writeln!(s, "        # the outputs, back to the host");
    for (j, &o) in p.outputs.iter().enumerate() {
        let v = &p.values[o];
        let _ = writeln!(
            s,
            "        var o_{j} = ctx.enqueue_create_host_buffer[DType.float32]({})\n        \
             ctx.enqueue_copy(dst_buf=o_{j}, src_buf=b_{})",
            v.len(),
            v.name
        );
    }
    let _ = writeln!(s, "        ctx.synchronize()");
    for (j, &o) in p.outputs.iter().enumerate() {
        let v = &p.values[o];
        let _ = writeln!(
            s,
            "        for i in range({}):\n            outputs[unsafe_offset={j}][unsafe_offset=i] = o_{j}[i]",
            v.len()
        );
    }
    s.push_str(
        r#"        return 0
    except e:
        print("xir_run failed:", e)
        return 1
"#,
    );
    s
}
