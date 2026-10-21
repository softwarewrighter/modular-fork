//! Standalone CUDA comparison for the elementwise XIR subset.
//! Uses the demo's f32 storage convention, including integer values.
use crate::ir::{MapOp, Op, Program, Ty};
use std::collections::HashMap;
use std::fmt::Write;

fn literal(x: f32) -> String {
    if x.is_nan() {
        "NAN".into()
    } else if x == f32::INFINITY {
        "INFINITY".into()
    } else if x == f32::NEG_INFINITY {
        "(-INFINITY)".into()
    } else {
        format!("{x:?}f")
    }
}

/// Emit a self-checking CUDA executable with inputs and oracle embedded.
/// Reductions are explicitly refused; they require a separate launch plan.
pub fn emit(
    p: &Program,
    inputs: &HashMap<String, Vec<f32>>,
    expected: &[Vec<f32>],
) -> Result<String, String> {
    if p.values.iter().any(|v| matches!(v.op, Op::Reduce(..))) {
        return Err(
            "CUDA comparison currently supports elementwise programs only (no reductions)".into(),
        );
    }
    if expected.len() != p.outputs.len()
        || expected
            .iter()
            .zip(&p.outputs)
            .any(|(a, &o)| a.len() != p.values[o].len())
    {
        return Err("CUDA oracle shape mismatch".into());
    }
    let mut s = String::from("// Generated from XIR by xir-mojo emit-cuda. Integers carried in float (exact to 2^24).\n#include <cmath>\n#include <cstdio>\n#include <cstdlib>\n#ifndef XIR_CPU_ONLY\n#include <cuda_runtime.h>\n#define HD __host__ __device__\n#define CUDA(call) do { cudaError_t e = (call); if (e != cudaSuccess) { std::fprintf(stderr, \"%s: %s\\n\", #call, cudaGetErrorString(e)); std::exit(2); } } while (0)\n#else\n#define HD\n#endif\n");
    let mut sources = Vec::new();
    for (i, v) in p.values.iter().enumerate() {
        let data = match &v.op {
            Op::Input => Some(
                inputs
                    .get(&v.name)
                    .ok_or_else(|| format!("unbound input %{}", v.name))?
                    .clone(),
            ),
            Op::Const(xs) if v.is_vector() => Some(if xs.len() == 1 {
                vec![xs[0]; v.len()]
            } else {
                xs.clone()
            }),
            _ => None,
        };
        if let Some(data) = data {
            if data.len() != v.len() {
                return Err("CUDA input shape mismatch".into());
            }
            writeln!(
                s,
                "static float h_{i}[] = {{{}}};",
                data.iter()
                    .map(|&x| literal(x))
                    .collect::<Vec<_>>()
                    .join(", ")
            )
            .unwrap();
            sources.push(i);
        }
    }
    let mut params = sources
        .iter()
        .map(|i| format!("const float* b_{i}"))
        .collect::<Vec<_>>();
    params.extend(
        p.outputs
            .iter()
            .enumerate()
            .map(|(j, _)| format!("float* out_{j}")),
    );
    let signature = params.join(", ");
    writeln!(s, "HD inline void element(int i, {signature}) {{").unwrap();
    for (i, v) in p.values.iter().enumerate() {
        let a = |j: usize| format!("v_{j}");
        let expr = match &v.op {
            Op::Input => format!("b_{i}[{}]", if v.is_vector() { "i" } else { "0" }),
            Op::Const(xs) => {
                if v.is_vector() {
                    format!("b_{i}[i]")
                } else {
                    literal(xs[0])
                }
            }
            Op::Select(c, x, y) => format!("{} ? {} : {}", a(*c), a(*x), a(*y)),
            Op::Cast(x) => match v.ty {
                Ty::Bool => format!("{} != 0.0f", a(*x)),
                Ty::I64 => format!("truncf({})", a(*x)),
                Ty::F32 => format!("float({})", a(*x)),
            },
            Op::Map(op, args) => {
                use MapOp::*;
                let x = a(args[0]);
                let y = args.get(1).map(|&i| a(i)).unwrap_or_default();
                match op {
                    Add | Sub | Mul | Div | Eq | Ne | Lt | Le | Gt | Ge | And | Or => {
                        let symbol = match op { Add => "+", Sub => "-", Mul => "*", Div => "/", Eq => "==", Ne => "!=", Lt => "<", Le => "<=", Gt => ">", Ge => ">=", And => "&&", Or => "||", _ => unreachable!() };
                        format!("{x} {symbol} {y}")
                    }
                    Mod if v.ty == Ty::I64 => format!("float((static_cast<long long>({x}) % static_cast<long long>({y})) + (((static_cast<long long>({x}) % static_cast<long long>({y})) != 0 && (({x} < 0) != ({y} < 0))) ? static_cast<long long>({y}) : 0))"),
                    Mod => format!("{x} - {y} * floorf({x} / {y})"),
                    Min => format!("fminf({x}, {y})"), Max => format!("fmaxf({x}, {y})"),
                    Neg => format!("-{x}"), Not => format!("!{x}"),
                    Abs => format!("fabsf({x})"), Exp => format!("expf({x})"), Log => format!("logf({x})"),
                }
            }
            Op::Reduce(..) => unreachable!(),
        };
        writeln!(
            s,
            "    {} v_{i} = {expr}; // %{}",
            if v.ty == Ty::Bool { "bool" } else { "float" },
            v.name
        )
        .unwrap();
    }
    for (j, &o) in p.outputs.iter().enumerate() {
        if p.values[o].is_vector() {
            writeln!(s, "    out_{j}[i] = float(v_{o});").unwrap();
        } else {
            writeln!(s, "    if (i == 0) out_{j}[0] = float(v_{o});").unwrap();
        }
    }
    s.push_str("}\n#ifndef XIR_CPU_ONLY\n");
    let mut args = sources.iter().map(|i| format!("b_{i}")).collect::<Vec<_>>();
    args.extend(
        p.outputs
            .iter()
            .enumerate()
            .map(|(j, _)| format!("out_{j}")),
    );
    writeln!(s, "extern \"C\" __global__ void stage0({signature}) {{\n    int i = blockIdx.x * blockDim.x + threadIdx.x;\n    if (i < {}) element(i, {});\n}}\n#endif\nint main() {{", p.n, args.join(", ")).unwrap();
    for &i in &sources {
        writeln!(s, "#ifndef XIR_CPU_ONLY\n    float* b_{i};\n    CUDA(cudaMalloc(&b_{i}, sizeof(h_{i})));\n    CUDA(cudaMemcpy(b_{i}, h_{i}, sizeof(h_{i}), cudaMemcpyHostToDevice));\n#else\n    float* b_{i} = h_{i};\n#endif").unwrap();
    }
    for (j, &o) in p.outputs.iter().enumerate() {
        writeln!(s, "    float result_{j}[{}];\n#ifndef XIR_CPU_ONLY\n    float* out_{j};\n    CUDA(cudaMalloc(&out_{j}, sizeof(result_{j})));\n#else\n    float* out_{j} = result_{j};\n#endif", p.values[o].len()).unwrap();
    }
    writeln!(s, "#ifndef XIR_CPU_ONLY\n    stage0<<<{}, 256>>>({});\n    CUDA(cudaGetLastError());\n    CUDA(cudaDeviceSynchronize());\n#else\n    for (int i = 0; i < {}; ++i) element(i, {});\n#endif\n    int failures = 0;", p.n.div_ceil(256), args.join(", "), p.n, args.join(", ")).unwrap();
    for (j, &o) in p.outputs.iter().enumerate() {
        writeln!(s, "#ifndef XIR_CPU_ONLY\n    CUDA(cudaMemcpy(result_{j}, out_{j}, sizeof(result_{j}), cudaMemcpyDeviceToHost));\n    CUDA(cudaFree(out_{j}));\n#endif\n    const float expected_{j}[] = {{{}}};\n    std::printf(\"output %%{}:\");\n    for (int i = 0; i < {}; ++i) {{\n        float g = result_{j}[i], w = expected_{j}[i];\n        std::printf(\" %.9g\", g);", expected[j].iter().map(|&x| literal(x)).collect::<Vec<_>>().join(", "), p.values[o].name, p.values[o].len()).unwrap();
        let condition = if p.values[o].ty == Ty::F32 {
            "!std::isfinite(g) || !std::isfinite(w) || (fabsf(g-w) > 1e-6f && fabsf(g-w) > 1e-4f * fabsf(w))"
        } else {
            "g != w"
        };
        writeln!(
            s,
            "        if ({condition}) ++failures;\n    }}\n    std::puts(\"\");"
        )
        .unwrap();
    }
    for &i in &sources {
        writeln!(
            s,
            "#ifndef XIR_CPU_ONLY\n    CUDA(cudaFree(b_{i}));\n#endif"
        )
        .unwrap();
    }
    s.push_str("#ifdef XIR_CPU_ONLY\n    std::puts(\"backend: CPU expression check (no GPU execution)\");\n#else\n    std::puts(\"backend: CUDA\");\n#endif\n    std::printf(\"RESULT: %d mismatched elements\\n\", failures);\n    return failures ? 1 : 0;\n}\n");
    Ok(s)
}
