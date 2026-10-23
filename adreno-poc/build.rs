use std::{env, fs, path::PathBuf};

fn main() {
    println!("cargo:rerun-if-changed=shaders/vector_add.comp");
    let source = fs::read_to_string("shaders/vector_add.comp").unwrap();
    let module = naga::front::glsl::Frontend::default()
        .parse(
            &naga::front::glsl::Options::from(naga::ShaderStage::Compute),
            &source,
        )
        .expect("parse vector-add GLSL");
    let info = naga::valid::Validator::new(
        naga::valid::ValidationFlags::all(),
        naga::valid::Capabilities::all(),
    )
    .validate(&module)
    .expect("validate vector-add shader");
    let words = naga::back::spv::write_vec(
        &module,
        &info,
        &naga::back::spv::Options::default(),
        Some(&naga::back::spv::PipelineOptions {
            shader_stage: naga::ShaderStage::Compute,
            entry_point: "main".into(),
        }),
    )
    .expect("emit SPIR-V");
    let bytes: Vec<u8> = words.iter().flat_map(|w| w.to_le_bytes()).collect();
    fs::write(
        PathBuf::from(env::var_os("OUT_DIR").unwrap()).join("vector_add.spv"),
        bytes,
    )
    .unwrap();
}
