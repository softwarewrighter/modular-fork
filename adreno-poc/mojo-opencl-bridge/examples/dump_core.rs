//! Capture exactly the loaded front-end program consumed by X_eTaL-gpu.
fn main() {
    let args: Vec<_> = std::env::args().collect();
    assert_eq!(args.len(), 3, "dump_core SOURCE OUTPUT_DIRECTORY");
    let source = std::fs::read_to_string(&args[1]).unwrap();
    let loaded = xetal_program::load(&args[1], &source).unwrap();
    let out = std::path::Path::new(&args[2]);
    std::fs::create_dir_all(out).unwrap();
    std::fs::write(out.join("threshold.core"), loaded.program.to_string()).unwrap();
    std::fs::write(
        out.join("threshold.combined.xtl"),
        loaded.sources.combined(),
    )
    .unwrap();
}
