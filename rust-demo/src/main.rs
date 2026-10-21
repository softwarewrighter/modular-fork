//! xir-mojo: Rust writes Mojo GPU code from a small array IR, builds it as a
//! shared library with `mojo build --emit shared-lib`, loads it, runs it on
//! the GPU, and checks the device against a Rust reference.
//!
//!     xir-mojo run programs/saxpy.xir [--inputs FILE] [--expect FILE] [--show-mojo] [--emit-only] [--dump-asm] [--cpu] [--work DIR]
//!     xir-mojo check programs/saxpy.xir          # parse, check, evaluate the reference only
//!
//! `--expect FILE` (or `PROGRAM.expect` beside the program) holds what the
//! X_eTaL evaluator printed for the same program, one line per output; the
//! device is then checked against it too, as X_eTaL-gpu's gate checks OpenCL.

use xir_mojo::{cuda, emit, eval, host, ir};

use std::collections::{BTreeMap, HashMap};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::exit;

struct Args {
    command: String,
    program: PathBuf,
    inputs: Option<PathBuf>,
    expect: Option<PathBuf>,
    work: Option<PathBuf>,
    show_mojo: bool,
    emit_only: bool,
    dump_asm: bool,
    cpu: bool,
}

fn usage() -> ! {
    eprintln!(
        "usage: xir-mojo run PROGRAM.xir [--inputs FILE] [--expect FILE] [--show-mojo] [--emit-only] [--dump-asm] [--cpu] [--work DIR]\n       xir-mojo check PROGRAM.xir [--inputs FILE] [--expect FILE]\n       xir-mojo emit-cuda PROGRAM.xir [--inputs FILE] [--expect FILE] [--work DIR]\n  --cpu builds the same Mojo with -D XIR_CPU=true and runs it on the CPU (a parallel range, not a grid)"
    );
    exit(2)
}

fn parse_args() -> Args {
    let mut it = std::env::args().skip(1);
    let command = it.next().unwrap_or_else(|| usage());
    if command != "run" && command != "check" && command != "emit-cuda" {
        usage();
    }
    let mut args = Args {
        command,
        program: PathBuf::new(),
        inputs: None,
        expect: None,
        work: None,
        show_mojo: false,
        emit_only: false,
        dump_asm: false,
        cpu: false,
    };
    let mut positional = Vec::new();
    while let Some(a) = it.next() {
        match a.as_str() {
            "--inputs" => args.inputs = Some(PathBuf::from(it.next().unwrap_or_else(|| usage()))),
            "--expect" => args.expect = Some(PathBuf::from(it.next().unwrap_or_else(|| usage()))),
            "--work" => args.work = Some(PathBuf::from(it.next().unwrap_or_else(|| usage()))),
            "--show-mojo" => args.show_mojo = true,
            "--emit-only" => args.emit_only = true,
            "--dump-asm" => args.dump_asm = true,
            "--cpu" => args.cpu = true,
            other if other.starts_with("--") => usage(),
            other => positional.push(other.to_string()),
        }
    }
    if positional.len() != 1 {
        usage();
    }
    args.program = PathBuf::from(&positional[0]);
    args
}

/// Inputs file: one line per input, `%x = 1 2 3`, `%x = ramp [SCALE]` (i * SCALE),
/// or `%a = 2.0` for a single value.
fn read_inputs(p: &ir::Program, path: &Path) -> Result<HashMap<String, Vec<f32>>, String> {
    let text = fs::read_to_string(path).map_err(|e| format!("{}: {e}", path.display()))?;
    let mut bound = HashMap::new();
    for (i, raw) in text.lines().enumerate() {
        let line = i + 1;
        let t = raw.split('#').next().unwrap().trim();
        if t.is_empty() {
            continue;
        }
        let (lhs, rhs) = t
            .split_once('=')
            .ok_or_else(|| format!("{}:{line}: `%name = items`", path.display()))?;
        let name = lhs.trim().trim_start_matches('%').to_string();
        let idx = p
            .index_of(&name)
            .ok_or_else(|| format!("{}:{line}: no value %{name} in the program", path.display()))?;
        let len = p.values[idx].len();
        let words: Vec<&str> = rhs.split_whitespace().collect();
        let items: Vec<f32> = if words.first() == Some(&"ramp") {
            let scale: f32 = words.get(1).map(|s| s.parse().unwrap_or(1.0)).unwrap_or(1.0);
            (0..len).map(|i| i as f32 * scale).collect()
        } else {
            words
                .iter()
                .map(|w| w.parse::<f32>().map_err(|_| format!("{}:{line}: `{w}` is not a number", path.display())))
                .collect::<Result<_, _>>()?
        };
        bound.insert(name, items);
    }
    Ok(bound)
}

/// The X_eTaL evaluator's output for the program: one line per `output`,
/// the items as `xetal` prints them (Ints without a point, Floats with one).
fn read_expect(p: &ir::Program, path: &Path) -> Result<Vec<Vec<f32>>, String> {
    let text = fs::read_to_string(path).map_err(|e| format!("{}: {e}", path.display()))?;
    let lines: Vec<&str> = text.lines().filter(|l| !l.trim().is_empty() && !l.starts_with('#')).collect();
    if lines.len() != p.outputs.len() {
        return Err(format!(
            "{}: {} line(s) for {} output(s)",
            path.display(),
            lines.len(),
            p.outputs.len()
        ));
    }
    lines
        .iter()
        .enumerate()
        .map(|(j, l)| {
            l.split_whitespace()
                .map(|w| {
                    w.parse::<f32>()
                        .map_err(|_| format!("{}:{}: `{w}` is not a number", path.display(), j + 1))
                })
                .collect()
        })
        .collect()
}

fn show(v: &[f32], ty: ir::Ty) -> String {
    let items: Vec<String> = v
        .iter()
        .map(|x| match ty {
            ir::Ty::Bool => (if *x != 0.0 { "1" } else { "0" }).to_string(),
            ir::Ty::I64 => format!("{}", *x as i64),
            ir::Ty::F32 => format!("{x:?}"),
        })
        .collect();
    let joined = items.join(" ");
    if joined.len() > 110 {
        format!("{} ... {} ({} items)", items[..6].join(" "), items[items.len() - 3..].join(" "), items.len())
    } else {
        joined
    }
}

/// Exact for bools and ints. For floats, each item must be within a relative 1e-4
/// (or an absolute 1e-6 near zero), since the device's tree reduction folds in
/// another order than the reference; the largest relative difference is reported.
fn compare(gpu: &[f32], want: &[f32], ty: ir::Ty) -> (bool, f32) {
    if gpu.len() != want.len() {
        return (false, f32::INFINITY);
    }
    let mut worst = 0f32;
    let mut ok = true;
    for (g, w) in gpu.iter().zip(want) {
        if ty == ir::Ty::Bool {
            if (*g != 0.0) != (*w != 0.0) {
                ok = false;
                worst = 1.0;
            }
            continue;
        }
        if ty == ir::Ty::I64 {
            if g != w {
                ok = false;
                worst = 1.0;
            }
            continue;
        }
        let abs = (g - w).abs();
        let rel = abs / w.abs().max(1e-6);
        if abs.is_nan() || (rel > 1e-4 && abs > 1e-6) {
            ok = false;
        }
        worst = worst.max(rel);
    }
    (ok, worst)
}

fn main() {
    let args = parse_args();
    if let Err(e) = real_main(&args) {
        eprintln!("xir-mojo: {e}");
        exit(1);
    }
}

fn real_main(args: &Args) -> Result<(), String> {
    let stem = args
        .program
        .file_stem()
        .and_then(|s| s.to_str())
        .ok_or("program path has no stem")?
        .to_string();
    let src = fs::read_to_string(&args.program).map_err(|e| format!("{}: {e}", args.program.display()))?;
    let program = ir::parse(&src).map_err(|e| format!("{}: {e}", args.program.display()))?;
    let inputs_path = args.inputs.clone().unwrap_or_else(|| args.program.with_extension("inputs"));
    let bound = if program.inputs().is_empty() && !inputs_path.exists() {
        HashMap::new()
    } else {
        read_inputs(&program, &inputs_path)?
    };
    let reference = eval::run(&program, &bound)?;
    let expect_path = args.expect.clone().unwrap_or_else(|| args.program.with_extension("expect"));
    let expected = if args.expect.is_some() || expect_path.exists() {
        Some(read_expect(&program, &expect_path)?)
    } else {
        None
    };
    let plan = emit::plan(&program);

    if args.command == "emit-cuda" {
        if let Some(expected) = &expected {
            for (j, &o) in program.outputs.iter().enumerate() {
                if !compare(&reference[j], &expected[j], program.values[o].ty).0 {
                    return Err("the Rust reference disagrees with the X_eTaL evaluator".into());
                }
            }
        }
        let text = cuda::emit(&program, &bound, expected.as_deref().unwrap_or(&reference))?;
        let dir = args
            .work
            .clone()
            .unwrap_or_else(|| host::experiment_root().join("work"))
            .join(&stem);
        fs::create_dir_all(&dir).map_err(|e| e.to_string())?;
        let path = dir.join(format!("{stem}.cu"));
        fs::write(&path, text).map_err(|e| e.to_string())?;
        println!("generated: {}", path.display());
        return Ok(());
    }


    println!("program: {} ({})", stem, args.program.display());
    println!(
        "  N = {} elements; {} value(s), {} input(s), {} output(s); {} fused kernel stage(s), {} reduction(s), {} device buffer(s)",
        program.n,
        program.values.len(),
        program.inputs().len(),
        program.outputs.len(),
        plan.kernels(),
        plan.reductions(),
        plan.buffers()
    );
    if args.command == "check" {
        let mut agreed = 0;
        for (j, &o) in program.outputs.iter().enumerate() {
            let v = &program.values[o];
            println!("output %{}\n  reference: {}", v.name, show(&reference[j], v.ty));
            if let Some(exp) = &expected {
                let (ok, worst) = compare(&reference[j], &exp[j], v.ty);
                println!("  xetal:     {}", show(&exp[j], v.ty));
                println!("  {}", if ok { if worst == 0.0 { "agree (exact)" } else { "agree" } } else { "DISAGREE" });
                agreed += ok as usize;
            }
        }
        if let Some(_) = &expected {
            println!(
                "RESULT: {} of {} reference outputs agree with the X_eTaL evaluator ({})",
                agreed,
                program.outputs.len(),
                expect_path.display()
            );
            if agreed != program.outputs.len() {
                return Err("the Rust reference disagrees with the X_eTaL evaluator".into());
            }
        }
        return Ok(());
    }

    let work = args
        .work
        .clone()
        .unwrap_or_else(|| host::experiment_root().join("work"))
        .join(&stem);
    fs::create_dir_all(&work).map_err(|e| format!("{}: {e}", work.display()))?;
    let mojo_src = work.join(format!("{stem}.mojo"));
    let text = emit::emit(&program, &plan, &stem);
    fs::write(&mojo_src, &text).map_err(|e| format!("{}: {e}", mojo_src.display()))?;
    println!("generated: {} ({} lines of Mojo)", mojo_src.display(), text.lines().count());
    if args.show_mojo {
        println!("----- {} -----\n{}----- end -----", mojo_src.display(), text);
    }
    if args.emit_only {
        return Ok(());
    }

    let mojo = host::mojo_path();
    let lib = work.join(format!("lib{stem}{}.{}", if args.cpu { "-cpu" } else { "" }, host::lib_ext()));
    let took = host::build(&mojo, &mojo_src, &lib, args.dump_asm, args.cpu)?;
    println!(
        "built: {} ({} build --emit shared-lib{}{}) in {:.1} s",
        lib.display(),
        mojo.display(),
        if args.dump_asm { " -D DUMP_GPU_ASM=true" } else { "" },
        if args.cpu { " -D XIR_CPU=true" } else { "" },
        took.as_secs_f64()
    );

    let kernel = host::Kernel::load(&lib)?;
    let has_gpu = kernel.init()?;
    if args.cpu {
        println!("cpu: the same source built with -D XIR_CPU=true; a CPU DeviceContext, each stage a parallel range over the elements (has_accelerator() = {})", has_gpu == 1);
    } else if has_gpu != 1 {
        return Err("the library was compiled without a GPU target (has_accelerator() is False)".into());
    }
    let info = kernel.device_info()?;
    println!("device: {}", info.replace(';', "  "));
    if args.cpu {
        println!("launch: a parallel range of {} element(s) on the CPU (no grid)", program.n);
    } else {
        let (blocks, tpb) = kernel.launch()?;
        println!("launch: {} block(s) of {} threads for {} element(s)", blocks, tpb, program.n);
    }

    let input_vecs: Vec<Vec<f32>> = program
        .inputs()
        .iter()
        .map(|&i| bound[&program.values[i].name].clone())
        .collect();
    let mut outputs: Vec<Vec<f32>> = program
        .outputs
        .iter()
        .map(|&o| vec![f32::NAN; program.values[o].len()])
        .collect();
    let dump = args.dump_asm && !args.cpu;
    if dump {
        println!("---- GPU assembly, as the device compiler received it (DUMP_GPU_ASM) ----");
    }
    let ran = kernel.run(&input_vecs, &mut outputs, program.n)?;
    if dump {
        println!("---- end of GPU assembly ----");
    }
    if args.cpu {
        println!("ran: xir_run in {:.2} ms on the CPU (includes the copies; speed is not the point)", ran.as_secs_f64() * 1e3);
        println!("proof: none to read back; on the CPU there is no block or thread, xir_trace returns 3");
    } else {
        println!("ran: xir_run in {:.2} ms (includes the first-use kernel compile, uploads and downloads; speed is not the point)", ran.as_secs_f64() * 1e3);
        let (block_of, thread_of) = kernel.trace(program.n)?;
        let mut per_block: BTreeMap<i32, usize> = BTreeMap::new();
        for b in &block_of {
            *per_block.entry(*b).or_default() += 1;
        }
        let last = program.n - 1;
        println!(
            "proof: element 0 computed by block {} thread {}; element {} by block {} thread {}; {} distinct block(s), {} distinct thread index(es)",
            block_of[0],
            thread_of[0],
            last,
            block_of[last],
            thread_of[last],
            per_block.len(),
            {
                let mut t: Vec<i32> = thread_of.clone();
                t.sort();
                t.dedup();
                t.len()
            }
        );
        if per_block.len() > 1 {
            let summary: Vec<String> = per_block.iter().map(|(b, c)| format!("block {b}: {c}")).collect();
            println!("       elements per block: {}", summary.join(", "));
        }
    }

    let mut agreed = 0;
    let mut agreed_xetal = 0;
    for (j, &o) in program.outputs.iter().enumerate() {
        let v = &program.values[o];
        let (ok, worst) = compare(&outputs[j], &reference[j], v.ty);
        println!(
            "output %{}\n  {}       {}\n  reference: {}",
            v.name,
            if args.cpu { "cpu:" } else { "gpu:" },
            show(&outputs[j], v.ty),
            show(&reference[j], v.ty)
        );
        if let Some(exp) = &expected {
            println!("  xetal:     {}", show(&exp[j], v.ty));
        }
        if ok {
            agreed += 1;
            if worst == 0.0 {
                println!("  agree (exact)");
            } else {
                println!("  agree (largest relative difference {worst:.2e}; the device folds reductions in another order)");
            }
        } else {
            println!("  DISAGREE (largest relative difference {worst:.2e})");
        }
        if let Some(exp) = &expected {
            let (ok_x, worst_x) = compare(&outputs[j], &exp[j], v.ty);
            if ok_x {
                agreed_xetal += 1;
                if worst_x != 0.0 {
                    println!("  agree with the X_eTaL evaluator (largest relative difference {worst_x:.2e})");
                }
            } else {
                println!("  DISAGREE with the X_eTaL evaluator (largest relative difference {worst_x:.2e})");
            }
        }
    }
    let n_out = program.outputs.len();
    if expected.is_some() {
        println!(
            "RESULT: {agreed} of {n_out} outputs agree with the Rust reference; {agreed_xetal} of {n_out} with the X_eTaL evaluator ({})",
            expect_path.display()
        );
    } else {
        println!("RESULT: {agreed} of {n_out} outputs agree with the Rust reference");
    }
    if agreed != n_out || (expected.is_some() && agreed_xetal != n_out) {
        return Err("the device disagrees with the reference".into());
    }
    Ok(())
}
