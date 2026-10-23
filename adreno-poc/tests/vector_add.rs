use adreno_vk::{check_output, inputs, run_vector_add};

#[test]
fn oracle_checks_every_element_and_rejects_nonfinite_results() {
    let (a, b) = inputs(1025);
    let expected: Vec<f32> = a.iter().zip(&b).map(|(x, y)| x + y).collect();
    assert!(check_output(&a, &b, &expected).is_ok());
    for index in [0, 512, 1024] {
        let mut bad = expected.clone();
        bad[index] += 1.0;
        assert!(check_output(&a, &b, &bad).is_err());
    }
    let mut bad = expected.clone();
    bad[100] = f32::NAN;
    assert!(check_output(&a, &b, &bad).is_err());
    bad[100] = f32::INFINITY;
    assert!(check_output(&a, &b, &bad).is_err());
    assert!(check_output(&a, &b, &expected[..1024]).is_err());
}

#[test]
fn invalid_counts_fail_before_loading_a_driver() {
    assert!(run_vector_add(0).is_err());
    assert!(run_vector_add(1048577).is_err());
    assert!(run_vector_add(usize::MAX).is_err());
}

#[test]
#[ignore = "requires a physical Vulkan GPU; run explicitly"]
fn physical_gpu_checks_aligned_and_partial_workgroups() {
    for n in [1, 1024, 1025, 65536, 1048576] {
        run_vector_add(n).unwrap();
    }
}
