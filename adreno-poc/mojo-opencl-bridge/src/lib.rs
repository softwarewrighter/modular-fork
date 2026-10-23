//! Versioned C ABI for the existing X_eTaL OpenCL path, called by Mojo.
pub mod spirv;
use std::collections::HashMap;
use xetal_gpu_opencl::{plan, Schedule};
use xetal_gpu_runtime::{devices, execute_timed};
use xetal_gpu_xir::{check, text, Array, Data, Shape};

/// The Float portion of Accel/threshold.xtl, with host-supplied x values.
pub fn program(n: usize) -> String {
    format!(
        "%x = input f64 [{n}]\n\
         %t = const f64 [] 0.5\n\
         %gt = map gt %x %t\n\
         %mask = cast f64 %gt\n\
         %threshold = map mul %x %mask\n\
         %zero = const f64 [] 0.0\n\
         %relu = map max %x %zero\n\
         output %x\noutput %threshold\noutput %relu\n"
    )
}

fn dispatch(input: &[f32]) -> Result<Vec<f32>, String> {
    let found = devices().map_err(|e| e.to_string())?;
    let candidates: Vec<_> = found
        .iter()
        .filter(|d| {
            d.name == "FD702"
                && d.vendor == "Qualcomm"
                && d.kind == "GPU"
                && d.platform == "rusticl"
        })
        .collect();
    if candidates.len() != 1 {
        return Err(format!(
            "expected one physical rusticl Qualcomm FD702, found {}",
            candidates.len()
        ));
    }
    let device = candidates[0];
    eprintln!(
        "Mojo bridge: opencl:{} {} ({}, {}; {})",
        device.index, device.name, device.kind, device.vendor, device.platform
    );
    let checked = check(text::parse(&program(input.len())).map_err(|e| e.to_string())?)
        .map_err(|e| e.to_string())?;
    let schedule = Schedule::from_toml(include_str!("../../schedules/adreno-702.toml"))?;
    let inputs = HashMap::from([(
        "x".into(),
        Array::floats(
            Shape(vec![input.len()]),
            input.iter().map(|x| *x as f64).collect(),
        ),
    )]);
    let execution_plan = plan(&checked, &schedule);
    if let Some(dir) = std::env::var_os("ADRENO_DUMP_DIR") {
        let dir = std::path::PathBuf::from(dir);
        std::fs::create_dir_all(&dir).map_err(|e| e.to_string())?;
        std::fs::write(dir.join("threshold.xir"), program(input.len()))
            .map_err(|e| e.to_string())?;
        std::fs::write(dir.join("threshold.cl"), &execution_plan.source)
            .map_err(|e| e.to_string())?;
    }
    let (outputs, timing) = execute_timed(&checked, &execution_plan, &inputs, device.index)
        .map_err(|e| e.to_string())?;
    eprintln!(
        "OpenCL device kernels: {:.6} ms; total {:.3} ms",
        timing.kernels_ms, timing.total_ms
    );
    let mut result = Vec::with_capacity(input.len() * 3);
    for output in outputs {
        let Data::Float(values) = output.data else {
            return Err("unexpected non-Float output".into());
        };
        result.extend(values.into_iter().map(|x| x as f32));
    }
    if result.len() != input.len() * 3 {
        return Err("output shape mismatch".into());
    }
    Ok(result)
}

/// Run x, threshold(x, 0.5), and relu(x) on physical FD702. Returns 0 on
/// success, -1 for invalid arguments, -2 for runtime failure, -3 for panic.
///
/// # Safety
/// input must reference n readable floats, output output_len writable floats.
/// The two regions must not overlap; their allocations must remain live.
#[no_mangle]
pub unsafe extern "C" fn adreno_threshold_v1(
    input: *const f32,
    output: *mut f32,
    n: usize,
    output_len: usize,
) -> i32 {
    if input.is_null() || output.is_null() || !(1..=1048576).contains(&n) || output_len != 3 * n {
        return -1;
    }
    match std::panic::catch_unwind(|| dispatch(std::slice::from_raw_parts(input, n))) {
        Ok(Ok(values)) => {
            std::ptr::copy_nonoverlapping(values.as_ptr(), output, output_len);
            0
        }
        Ok(Err(err)) => {
            eprintln!("Adreno bridge error: {err}");
            -2
        }
        Err(_) => {
            eprintln!("Adreno bridge panicked");
            -3
        }
    }
}
