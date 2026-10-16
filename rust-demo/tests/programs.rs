//! Tests without a GPU: the parser and checker, the Rust reference, the plan
//! and the emitted Mojo text, over the programs in `programs/`.

use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;
use xir_mojo::{emit, eval, ir};

fn root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

fn program(name: &str) -> ir::Program {
    let src = fs::read_to_string(root().join(format!("programs/{name}.xir"))).unwrap();
    ir::parse(&src).unwrap_or_else(|e| panic!("{name}: {e}"))
}

fn ramp(n: usize, scale: f32) -> Vec<f32> {
    (0..n).map(|i| i as f32 * scale).collect()
}

#[test]
fn every_program_parses_plans_and_emits() {
    let dir = root().join("programs");
    let mut count = 0;
    for entry in fs::read_dir(&dir).unwrap() {
        let path = entry.unwrap().path();
        if path.extension().and_then(|e| e.to_str()) != Some("xir") {
            continue;
        }
        count += 1;
        let stem = path.file_stem().unwrap().to_str().unwrap().to_string();
        let src = fs::read_to_string(&path).unwrap();
        let p = ir::parse(&src).unwrap_or_else(|e| panic!("{stem}: {e}"));
        let plan = emit::plan(&p);
        let text = emit::emit(&p, &plan, &stem);
        assert!(text.contains("@export(\"xir_run\")"), "{stem}: no xir_run export");
        assert!(text.contains("@export(\"xir_trace\")"), "{stem}: no provenance export");
        if plan.kernels() > 0 {
            assert!(text.contains("def stage0("), "{stem}: no fused kernel");
        }
        assert_eq!(text.matches("def stage").count(), plan.kernels(), "{stem}: one def per kernel stage");
        assert_eq!(
            text.matches("ctx.enqueue_function[reduce_").count(),
            2 * plan.reductions(),
            "{stem}: two launches per reduction"
        );
        assert!(!text.contains("b_x[i]"), "{stem}: positional pointer indexing is deprecated in Mojo");
    }
    assert!(count >= 5, "expected the five example programs, found {count}");
}

#[test]
fn saxpy_reference_and_plan() {
    let p = program("saxpy");
    assert_eq!(p.n, 8);
    let plan = emit::plan(&p);
    assert_eq!((plan.kernels(), plan.reductions(), plan.buffers()), (1, 0, 2));
    let mut inputs = HashMap::new();
    inputs.insert("x".to_string(), ramp(8, 0.25));
    let out = eval::run(&p, &inputs).unwrap();
    assert_eq!(out[0], vec![1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5]);
    let text = emit::emit(&p, &plan, "saxpy");
    assert!(text.contains("var v_ax = Float32(2.0) * v_x"), "scalar consts are literals in the kernel");
    assert!(text.contains("var v_y = v_ax + Float32(1.0)"));
    assert!(text.contains("b_y[unsafe_offset=i] = v_y"));
}

#[test]
fn threshold_bools_round_trip_as_zero_and_one() {
    let p = program("threshold");
    let mut inputs = HashMap::new();
    inputs.insert("x".to_string(), ramp(16, 0.75));
    let out = eval::run(&p, &inputs).unwrap();
    let mask: Vec<f32> = (0..16).map(|i| if i as f32 * 0.75 > 5.0 { 1.0 } else { 0.0 }).collect();
    assert_eq!(out[0], mask);
    assert_eq!(out[1][6], 0.0);
    assert_eq!(out[1][7], 5.25);
    let text = emit::emit(&p, &emit::plan(&p), "threshold");
    assert!(text.contains("var v_m = Bool(v_x > Float32(5.0))"));
    assert!(text.contains("Float32(1.0) if v_m else Float32(0.0)"), "bools are stored as 0 or 1");
}

#[test]
fn reductions_fold_from_the_right_like_xetal() {
    let p = program("reduce");
    let mut inputs = HashMap::new();
    inputs.insert("x".to_string(), ramp(1000, 0.5));
    let out = eval::run(&p, &inputs).unwrap();
    assert_eq!(out[0][0], 249750.0);
    assert_eq!(out[1][0], 499.5);
    assert_eq!(out[2][0], 0.0);
    let plan = emit::plan(&p);
    assert_eq!((plan.kernels(), plan.reductions()), (0, 3));
    let text = emit::emit(&p, &plan, "reduce");
    for op in ["add", "max", "min"] {
        assert!(text.contains(&format!("def reduce_{op}(")), "a kernel per reduce op used");
    }
    // The order X_eTaL's r_/ folds: 0.1 + (0.2 + 0.3) prints 0.6, not 0.6000000000000001.
    let p = ir::parse("%x = input f32 [3]\n%s = reduce add %x\noutput %s\n").unwrap();
    let mut inputs = HashMap::new();
    inputs.insert("x".to_string(), vec![0.1f32, 0.2, 0.3]);
    let out = eval::run(&p, &inputs).unwrap();
    assert_eq!(out[0][0], 0.1f32 + (0.2f32 + 0.3f32));
}

#[test]
fn softmax_stages_split_at_reductions() {
    let p = program("softmax");
    let plan = emit::plan(&p);
    assert_eq!((plan.kernels(), plan.reductions()), (2, 3));
    assert_eq!(plan.stage(p.index_of("c").unwrap()), Some(0));
    assert_eq!(plan.stage(p.index_of("e").unwrap()), Some(0));
    assert_eq!(plan.stage(p.index_of("p").unwrap()), Some(1));
    let mut inputs = HashMap::new();
    inputs.insert("x".to_string(), ramp(1024, 0.01));
    let out = eval::run(&p, &inputs).unwrap();
    let total: f32 = out[0].iter().sum();
    assert!((total - 1.0).abs() < 1e-4, "probabilities sum to one: {total}");
    assert!((out[1][0] - 1.0).abs() < 1e-4);
}

#[test]
fn stats_single_value_maps_are_written_by_thread_zero() {
    let p = program("stats");
    let plan = emit::plan(&p);
    let text = emit::emit(&p, &plan, "stats");
    assert!(text.contains("if i == 0:\n            b_mean[unsafe_offset=0] = v_mean"));
    let mut inputs = HashMap::new();
    inputs.insert("x".to_string(), ramp(1000, 0.5));
    let out = eval::run(&p, &inputs).unwrap();
    assert_eq!(out[0][0], 249.75);
}

#[test]
fn the_checker_refuses_what_the_device_could_not_run() {
    let bad = [
        ("%x = input f32 [8]\n%y = map add %x %z\noutput %y\n", "not defined"),
        ("%x = input f32 [8]\n%y = input f32 [9]\n%z = map add %x %y\noutput %z\n", "one length"),
        ("%x = input f32 [8]\n%m = map gt %x %x\n%y = map add %m %x\noutput %y\n", "share one type"),
        ("%x = input f32 [8]\n%m = map gt %x %x\n%s = reduce add %m\noutput %s\n", "vector of numbers"),
        ("%x = input f32 [8]\n%y = map exp %x %x\noutput %y\n", "takes 1 argument"),
        ("%x = input f32 [8]\n%x = map neg %x\noutput %x\n", "defined twice"),
        ("%x = input f32 [8]\n", "no `output`"),
        ("%x = input f32 [8]\n%z = select %x %x %x\noutput %z\n", "condition is a bool"),
    ];
    for (src, needle) in bad {
        let err = ir::parse(src).expect_err(src);
        assert!(err.contains(needle), "{src:?}: {err}");
    }
}

/// The programs `xetal-gpu lower` wrote from X_eTaL source (`programs/accel-*.xir`)
/// parse, and the Rust reference gives what X_eTaL's own evaluator printed
/// for the same source (`programs/accel-*.expect`), exactly: no GPU needed
/// to know the two oracles agree.
#[test]
fn lowered_xetal_programs_match_the_evaluator() {
    let dir = root().join("programs");
    let mut seen = 0;
    for entry in fs::read_dir(&dir).unwrap() {
        let path = entry.unwrap().path();
        let stem = path.file_stem().unwrap().to_str().unwrap().to_string();
        if !stem.starts_with("accel-") || path.extension().and_then(|e| e.to_str()) != Some("xir") {
            continue;
        }
        seen += 1;
        let src = fs::read_to_string(&path).unwrap();
        assert!(src.starts_with("# "), "{stem}: no provenance header");
        assert!(src.contains("lowered by xetal-gpu"), "{stem}: not marked as lowered");
        let p = ir::parse(&src).unwrap_or_else(|e| panic!("{stem}: {e}"));
        let got = eval::run(&p, &HashMap::new()).unwrap_or_else(|e| panic!("{stem}: {e}"));
        let expect = fs::read_to_string(path.with_extension("expect")).unwrap();
        let lines: Vec<&str> = expect.lines().filter(|l| !l.starts_with('#') && !l.trim().is_empty()).collect();
        assert_eq!(lines.len(), p.outputs.len(), "{stem}: outputs vs evaluator lines");
        for (j, line) in lines.iter().enumerate() {
            let want: Vec<f32> = line.split_whitespace().map(|w| w.parse().unwrap()).collect();
            assert_eq!(got[j], want, "{stem}: output {j} ({})", p.values[p.outputs[j]].name);
        }
        // The emitted Mojo says which values are ints carried as Float32.
        let plan = emit::plan(&p);
        let text = emit::emit(&p, &plan, &stem);
        let has_ints = p.values.iter().any(|v| v.ty == ir::Ty::I64);
        assert_eq!(text.contains("i64 in the IR, carried as Float32"), has_ints, "{stem}");
    }
    assert_eq!(seen, 5, "five Accel demos lower into the subset");
}

#[test]
fn ints_cast_and_mod() {
    let p = ir::parse(
        "%a = const i64 [4] -3 -2 -1 4\n%two = const i64 [] 2\n%m = map mod %a %two\n\
         %f = cast f64 %a\n%h = const f64 [] 0.5\n%g = map mul %f %h\n%b = map gt %a %two\n%c = cast i64 %b\n\
         output %m\noutput %g\noutput %c\n",
    )
    .unwrap();
    let out = eval::run(&p, &HashMap::new()).unwrap();
    assert_eq!(out[0], vec![1.0, 0.0, 1.0, 0.0], "floored mod, the divisor's sign");
    assert_eq!(out[1], vec![-1.5, -1.0, -0.5, 2.0]);
    assert_eq!(out[2], vec![0.0, 0.0, 0.0, 1.0]);
    assert_eq!(p.values[p.index_of("m").unwrap()].ty, ir::Ty::I64);
    assert_eq!(p.values[p.index_of("c").unwrap()].ty, ir::Ty::I64);
    let plan = emit::plan(&p);
    let text = emit::emit(&p, &plan, "t");
    assert!(text.contains("Float32(Int(v_a) % Int(Float32(2.0)))"), "int mod goes through Mojo's Int %:\n{text}");
    assert!(text.contains("Float32(1.0) if v_b else Float32(0.0)"), "bool to int cast");

    let e = |s: &str| ir::parse(s).err().unwrap();
    assert!(e("%a = const i64 [] 16777217\noutput %a\n").contains("beyond 2^24"));
    assert!(e("%a = const i64 [2] 1 2\n%b = map div %a %a\noutput %b\n").contains("takes f32"));
    assert!(e("%a = const i64 [2] 1 2\n%b = map exp %a\noutput %b\n").contains("takes f32"));
    let big = ir::parse("%a = const i64 [2] 5000 5000\n%b = map mul %a %a\n%c = map mul %b %a\noutput %c\n").unwrap();
    assert!(eval::run(&big, &HashMap::new()).unwrap_err().contains("beyond 2^24"));
}
