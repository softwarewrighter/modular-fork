//! The host side: find `mojo`, build the generated source as a shared
//! library, load it with `dlopen`, and call its C exports.

use std::env;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{Duration, Instant};

pub fn experiment_root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).to_path_buf()
}

/// `$MOJO` if set, else the experiment's `.venv/bin/mojo`, else `mojo` on PATH.
pub fn mojo_path() -> PathBuf {
    if let Ok(p) = env::var("MOJO") {
        return PathBuf::from(p);
    }
    let venv = experiment_root().join(".venv/bin/mojo");
    if venv.exists() {
        return venv;
    }
    PathBuf::from("mojo")
}

pub fn lib_ext() -> &'static str {
    if cfg!(target_os = "macos") {
        "dylib"
    } else {
        "so"
    }
}

/// `mojo build SRC --emit shared-lib -o OUT`, with the GPU assembly dump
/// switched on when asked (the kernel's Metal AIR or PTX is then printed when
/// the kernel is first compiled, which happens inside this process at run time),
/// and `-D XIR_CPU=true` for the CPU build of the same source.
pub fn build(mojo: &Path, src: &Path, out: &Path, dump_asm: bool, cpu: bool) -> Result<Duration, String> {
    let start = Instant::now();
    let mut cmd = Command::new(mojo);
    cmd.arg("build").arg(src).args(["--emit", "shared-lib", "-o"]).arg(out);
    if dump_asm {
        cmd.args(["-D", "DUMP_GPU_ASM=true"]);
    }
    if cpu {
        cmd.args(["-D", "XIR_CPU=true"]);
    }
    let output = cmd
        .output()
        .map_err(|e| format!("could not run {}: {e} (run scripts/setup.sh, or set MOJO)", mojo.display()))?;
    let stderr = String::from_utf8_lossy(&output.stderr);
    let noise: Vec<&str> = stderr
        .lines()
        .filter(|l| !l.contains("Crashpad") && !l.trim().is_empty())
        .collect();
    if !output.status.success() {
        return Err(format!("mojo build failed:\n{}", noise.join("\n")));
    }
    if !noise.is_empty() {
        eprintln!("{}", noise.join("\n"));
    }
    Ok(start.elapsed())
}

pub struct Kernel {
    lib: libloading::Library,
}

type InitFn = unsafe extern "C" fn() -> i32;
type InfoFn = unsafe extern "C" fn(*mut u8, i64) -> i64;
type LaunchFn = unsafe extern "C" fn(*mut i32, *mut i32) -> i32;
type TraceFn = unsafe extern "C" fn(*mut i32, *mut i32, i64) -> i32;
type RunFn = unsafe extern "C" fn(*const *const f32, *const *mut f32, i64) -> i32;

impl Kernel {
    pub fn load(path: &Path) -> Result<Kernel, String> {
        let lib = unsafe { libloading::Library::new(path) }
            .map_err(|e| format!("dlopen {}: {e}", path.display()))?;
        Ok(Kernel { lib })
    }

    fn sym<T>(&self, name: &[u8]) -> Result<libloading::Symbol<'_, T>, String> {
        unsafe { self.lib.get(name) }
            .map_err(|e| format!("symbol {}: {e}", String::from_utf8_lossy(name)))
    }

    pub fn init(&self) -> Result<i32, String> {
        let f: libloading::Symbol<InitFn> = self.sym(b"xir_init")?;
        Ok(unsafe { f() })
    }

    pub fn device_info(&self) -> Result<String, String> {
        let f: libloading::Symbol<InfoFn> = self.sym(b"xir_device_info")?;
        let mut buf = vec![0u8; 512];
        let n = unsafe { f(buf.as_mut_ptr(), buf.len() as i64) };
        if n < 0 {
            return Err("the library could not open a device (DeviceContext failed)".into());
        }
        Ok(String::from_utf8_lossy(&buf[..n as usize]).into_owned())
    }

    pub fn launch(&self) -> Result<(i32, i32), String> {
        let f: libloading::Symbol<LaunchFn> = self.sym(b"xir_launch")?;
        let (mut blocks, mut tpb) = (0i32, 0i32);
        unsafe { f(&mut blocks, &mut tpb) };
        Ok((blocks, tpb))
    }

    pub fn trace(&self, n: usize) -> Result<(Vec<i32>, Vec<i32>), String> {
        let f: libloading::Symbol<TraceFn> = self.sym(b"xir_trace")?;
        let mut blocks = vec![-1i32; n];
        let mut threads = vec![-1i32; n];
        let rc = unsafe { f(blocks.as_mut_ptr(), threads.as_mut_ptr(), n as i64) };
        if rc != 0 {
            return Err(format!("xir_trace returned {rc}"));
        }
        Ok((blocks, threads))
    }

    pub fn run(&self, inputs: &[Vec<f32>], outputs: &mut [Vec<f32>], n: usize) -> Result<Duration, String> {
        let f: libloading::Symbol<RunFn> = self.sym(b"xir_run")?;
        let in_ptrs: Vec<*const f32> = inputs.iter().map(|v| v.as_ptr()).collect();
        let out_ptrs: Vec<*mut f32> = outputs.iter_mut().map(|v| v.as_mut_ptr()).collect();
        let start = Instant::now();
        let rc = unsafe { f(in_ptrs.as_ptr(), out_ptrs.as_ptr(), n as i64) };
        match rc {
            0 => Ok(start.elapsed()),
            2 => Err("xir_run: the library was built for another N".into()),
            other => Err(format!("xir_run returned {other} (the device failed; see the message above)")),
        }
    }
}
