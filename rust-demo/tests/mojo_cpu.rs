//! Real Mojo compilation and execution; run explicitly after scripts/setup.sh.
use std::{collections::HashMap, fs, path::PathBuf, process::Command};
use xir_mojo::{emit, eval, host, ir};

#[test]
#[ignore = "requires the pinned Mojo toolchain"]
fn mojo_cpu_runs_and_rejects_wrong_oracle() {
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let p = ir::parse(&fs::read_to_string(root.join("programs/accel-threshold.xir")).unwrap()).unwrap();
    let inputs = HashMap::new();
    let mut expected = eval::run(&p, &inputs).unwrap();
    let dir = root.join("work/cpu-emitter-test");
    fs::create_dir_all(&dir).unwrap();
    let src = dir.join("test.mojo");
    let exe = dir.join("test");
    for wrong in [false, true] {
        if wrong { expected[0][0] = 99.; }
        fs::write(&src, emit::emit_cpu(&p, &inputs, &expected).unwrap()).unwrap();
        let build = Command::new(host::mojo_path()).arg("build").arg(&src).arg("-o").arg(&exe).output().unwrap();
        assert!(build.status.success(), "{}", String::from_utf8_lossy(&build.stderr));
        let run = Command::new(&exe).output().unwrap();
        assert_eq!(run.status.success(), !wrong, "{}", String::from_utf8_lossy(&run.stdout));
    }
}
