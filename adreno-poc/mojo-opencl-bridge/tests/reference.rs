use adreno_mojo_opencl::{adreno_threshold_v1, program};
use std::collections::HashMap;
use xetal_gpu_xir::{check, run, text, Array, Data, Shape};

#[test]
fn bridge_program_matches_xetal_threshold_float_baseline() {
    let checked = check(text::parse(&program(8)).unwrap()).unwrap();
    let input: Vec<_> = (1..=8).map(|i| i as f64 / 4.0 - 1.0).collect();
    let result = run(
        &checked,
        &HashMap::from([("x".into(), Array::floats(Shape(vec![8]), input))]),
    )
    .unwrap();
    let baseline = include_str!("../../docs/evidence/unoq-xetal-opencl-20261023/threshold.expect");
    for (got, line) in result.iter().zip(baseline.lines().take(3)) {
        let expected: Vec<f64> = line
            .split_whitespace()
            .map(|n| n.parse().unwrap())
            .collect();
        assert_eq!(got.data, Data::Float(expected));
    }
    assert_eq!(result.len(), 3);
}

#[test]
fn ffi_rejects_invalid_buffers_without_loading_opencl() {
    unsafe {
        assert_eq!(
            adreno_threshold_v1(std::ptr::null(), std::ptr::null_mut(), 8, 24),
            -1
        );
        let input = [0.0f32; 8];
        let mut output = [0.0f32; 24];
        assert_eq!(
            adreno_threshold_v1(input.as_ptr(), output.as_mut_ptr(), 0, 0),
            -1
        );
        assert_eq!(
            adreno_threshold_v1(input.as_ptr(), output.as_mut_ptr(), 8, 23),
            -1
        );
    }
}
