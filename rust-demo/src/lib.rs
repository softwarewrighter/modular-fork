//! xir-mojo: Rust emits Mojo GPU code from a tiny array IR, builds it as a
//! shared library, loads it, runs it on the GPU, and checks the device
//! against a Rust reference. See the README beside this crate.

pub mod cuda;
pub mod emit;
pub mod eval;
pub mod host;
pub mod ir;
