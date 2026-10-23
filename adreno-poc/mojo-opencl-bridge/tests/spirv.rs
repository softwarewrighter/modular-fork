use adreno_mojo_opencl::spirv::{adreno_run_spirv_v1, validate_il};

#[test]
fn rejects_malformed_il_before_loading_a_driver() {
    assert!(validate_il(&[]).is_err());
    assert!(validate_il(&[0; 20]).is_err());
    let mut header = vec![0u8; 20];
    header[..4].copy_from_slice(&0x07230203u32.to_le_bytes());
    header[4..8].copy_from_slice(&0x00010000u32.to_le_bytes());
    assert!(validate_il(&header).is_ok());
    header.push(0);
    assert!(validate_il(&header).is_err());
    unsafe {
        assert_eq!(
            adreno_run_spirv_v1(
                std::ptr::null(),
                0,
                std::ptr::null(),
                std::ptr::null_mut(),
                8,
                24
            ),
            -1
        );
    }
}
