//! The device gate: every program in `programs/` generated, built with
//! `mojo build --emit shared-lib`, loaded, run on the GPU, and its outputs
//! checked against the Rust reference by the tool itself. Needs the Mojo
//! toolchain (`scripts/setup.sh`) and a GPU; without them the test is
//! skipped with a note, unless XIR_REQUIRE_DEVICE=1 makes that a failure.
//!
//!     cargo test --release --test device -- --nocapture

use std::fs;
use std::path::PathBuf;
use std::process::Command;

fn root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

fn mojo_available() -> bool {
    let mojo = std::env::var("MOJO")
        .map(PathBuf::from)
        .unwrap_or_else(|_| root().join(".venv/bin/mojo"));
    mojo.exists()
}

#[test]
fn every_program_agrees_with_the_reference_on_the_device() {
    if !mojo_available() {
        let msg = "no Mojo toolchain (run scripts/setup.sh); the device gate did not run";
        if std::env::var("XIR_REQUIRE_DEVICE").is_ok() {
            panic!("{msg}");
        }
        eprintln!("SKIPPED: {msg}");
        return;
    }
    let mut programs: Vec<PathBuf> = fs::read_dir(root().join("programs"))
        .unwrap()
        .map(|e| e.unwrap().path())
        .filter(|p| p.extension().and_then(|e| e.to_str()) == Some("xir"))
        .collect();
    programs.sort();
    assert!(!programs.is_empty());
    let mut device = String::new();
    for p in &programs {
        let out = Command::new(env!("CARGO_BIN_EXE_xir-mojo"))
            .arg("run")
            .arg(p)
            .output()
            .expect("run the tool");
        let stdout = String::from_utf8_lossy(&out.stdout);
        let stderr = String::from_utf8_lossy(&out.stderr);
        assert!(
            out.status.success(),
            "{}: exit {:?}\n--- stdout\n{stdout}\n--- stderr\n{stderr}",
            p.display(),
            out.status.code()
        );
        let n_out = stdout.matches("\noutput %").count();
        let verdict = format!("RESULT: {n_out} of {n_out} outputs agree with the Rust reference");
        assert!(stdout.contains(&verdict), "{}: {stdout}", p.display());
        assert!(!stdout.contains("DISAGREE"), "{}: {stdout}", p.display());
        let dev = stdout
            .lines()
            .find(|l| l.starts_with("device: api="))
            .unwrap_or_else(|| panic!("{}: no device line\n{stdout}", p.display()))
            .to_string();
        assert!(!dev.contains("api=cpu"), "{}: ran on the CPU, not a GPU: {dev}", p.display());
        let proof = stdout
            .lines()
            .find(|l| l.starts_with("proof: element 0 computed by block 0 thread 0;"))
            .unwrap_or_else(|| panic!("{}: no provenance line\n{stdout}", p.display()));
        assert!(proof.contains("distinct thread index(es)"));
        if device.is_empty() {
            device = dev;
            eprintln!("{device}");
        }
        eprintln!("ok  {}", p.file_name().unwrap().to_str().unwrap());
    }
}
