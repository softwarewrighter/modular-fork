//! Load Mojo-authored, retargeted SPIR-V directly: no OpenCL C source emitter.
use opencl3::{
    command_queue::CommandQueue,
    context::Context,
    device::{get_all_devices, Device, CL_DEVICE_TYPE_ALL, CL_DEVICE_TYPE_GPU},
    kernel::Kernel,
    memory::{Buffer, CL_MEM_READ_ONLY, CL_MEM_READ_WRITE},
    program::Program,
    types::CL_BLOCKING,
};

const KERNEL: &str = "activation_gpu_activations_Po6A6AoA6A6A_2d28411a43ede716";

/// Check the supported SPIR-V header shape; the driver validates the module.
pub fn validate_il(bytes: &[u8]) -> Result<(), String> {
    if bytes.len() < 20
        || !bytes.len().is_multiple_of(4)
        || bytes[..4] != 0x07230203u32.to_le_bytes()
    {
        return Err("expected aligned little-endian SPIR-V header".into());
    }
    if bytes[4..8] != 0x00010000u32.to_le_bytes() {
        return Err("this experiment requires SPIR-V 1.0".into());
    }
    Ok(())
}

fn execute(il: &[u8], input: &[f32]) -> Result<Vec<f32>, String> {
    validate_il(il)?;
    let ids = get_all_devices(CL_DEVICE_TYPE_ALL).map_err(|e| e.to_string())?;
    let mut matches = Vec::new();
    for id in ids {
        let d = Device::new(id);
        if d.name().map_err(|e| e.to_string())? == "FD702"
            && d.vendor().map_err(|e| e.to_string())? == "Qualcomm"
            && d.dev_type().map_err(|e| e.to_string())? & CL_DEVICE_TYPE_GPU != 0
        {
            matches.push(d);
        }
    }
    if matches.len() != 1 {
        return Err(format!(
            "expected one physical FD702 GPU, found {}",
            matches.len()
        ));
    }
    let device = &matches[0];
    eprintln!(
        "SPIR-V device: {} ({}; GPU); driver {}; IL {}",
        device.name().map_err(|e| e.to_string())?,
        device.vendor().map_err(|e| e.to_string())?,
        device.driver_version().map_err(|e| e.to_string())?,
        device.il_version().map_err(|e| e.to_string())?
    );
    let context = Context::from_device(device).map_err(|e| e.to_string())?;
    let queue = CommandQueue::create_default(&context, 0).map_err(|e| e.to_string())?;
    let mut program =
        Program::create_from_il(&context, il).map_err(|e| format!("clCreateProgramWithIL: {e}"))?;
    if let Err(error) = program.build(context.devices(), "") {
        return Err(format!(
            "IL build: {error}; {}",
            program.get_build_log(device.id()).unwrap_or_default()
        ));
    }
    let kernel = Kernel::create(&program, KERNEL).map_err(|e| e.to_string())?;
    let n = input.len();
    let mut a =
        unsafe { Buffer::<f32>::create(&context, CL_MEM_READ_ONLY, n, std::ptr::null_mut()) }
            .map_err(|e| e.to_string())?;
    let mut threshold =
        unsafe { Buffer::<f32>::create(&context, CL_MEM_READ_WRITE, n, std::ptr::null_mut()) }
            .map_err(|e| e.to_string())?;
    let mut relu =
        unsafe { Buffer::<f32>::create(&context, CL_MEM_READ_WRITE, n, std::ptr::null_mut()) }
            .map_err(|e| e.to_string())?;
    let poison = vec![f32::NAN; n];
    let mut t = vec![f32::NAN; n];
    let mut r = vec![f32::NAN; n];
    // Blocking operations on an in-order queue retain all buffers and module
    // through completion. Every OpenCL error propagates across the ABI.
    unsafe {
        queue
            .enqueue_write_buffer(&mut a, CL_BLOCKING, 0, input, &[])
            .map_err(|e| e.to_string())?;
        queue
            .enqueue_write_buffer(&mut threshold, CL_BLOCKING, 0, &poison, &[])
            .map_err(|e| e.to_string())?;
        queue
            .enqueue_write_buffer(&mut relu, CL_BLOCKING, 0, &poison, &[])
            .map_err(|e| e.to_string())?;
        kernel.set_arg(0, &a).map_err(|e| e.to_string())?;
        kernel.set_arg(1, &threshold).map_err(|e| e.to_string())?;
        kernel.set_arg(2, &relu).map_err(|e| e.to_string())?;
        kernel.set_arg(3, &0.5f32).map_err(|e| e.to_string())?;
        kernel.set_arg(4, &(n as i32)).map_err(|e| e.to_string())?;
        let global = [n.div_ceil(64) * 64];
        let local = [64];
        let event = queue
            .enqueue_nd_range_kernel(
                kernel.get(),
                1,
                std::ptr::null(),
                global.as_ptr(),
                local.as_ptr(),
                &[],
            )
            .map_err(|e| e.to_string())?;
        event.wait().map_err(|e| e.to_string())?;
        queue
            .enqueue_read_buffer(&threshold, CL_BLOCKING, 0, &mut t, &[])
            .map_err(|e| e.to_string())?;
        queue
            .enqueue_read_buffer(&relu, CL_BLOCKING, 0, &mut r, &[])
            .map_err(|e| e.to_string())?;
    }
    eprintln!(
        "Mojo-authored SPIR-V dispatched: n={n}, local=64, global={}",
        n.div_ceil(64) * 64
    );
    Ok(input.iter().chain(&t).chain(&r).copied().collect())
}

/// Dispatch the supported Mojo SPIR-V activation kernel. Status: 0 success,
/// -1 invalid arguments, -2 OpenCL/module error, -3 caught Rust panic.
///
/// # Safety
/// il must reference il_len bytes, input n floats and output output_len
/// writable floats, with nonoverlapping allocations live through this call.
#[no_mangle]
pub unsafe extern "C" fn adreno_run_spirv_v1(
    il: *const u8,
    il_len: usize,
    input: *const f32,
    output: *mut f32,
    n: usize,
    output_len: usize,
) -> i32 {
    if il.is_null()
        || input.is_null()
        || output.is_null()
        || !(20..=16777216).contains(&il_len)
        || !(1..=1048576).contains(&n)
        || output_len != 3 * n
    {
        return -1;
    }
    match std::panic::catch_unwind(|| {
        execute(
            std::slice::from_raw_parts(il, il_len),
            std::slice::from_raw_parts(input, n),
        )
    }) {
        Ok(Ok(values)) => {
            std::ptr::copy_nonoverlapping(values.as_ptr(), output, output_len);
            0
        }
        Ok(Err(error)) => {
            eprintln!("SPIR-V bridge error: {error}");
            -2
        }
        Err(_) => {
            eprintln!("SPIR-V bridge panic");
            -3
        }
    }
}
