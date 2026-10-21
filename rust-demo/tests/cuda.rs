//! Execute emitted expressions with a host C++ compiler, independently of CUDA.
use std::{collections::HashMap, fs, process::Command};
use xir_mojo::{cuda, eval, ir};

#[test]
fn generated_cpp_checks_signed_mod_bools_scalar_outputs_and_casts() {
    let p = ir::parse("%x = input i64 [8]\n%pos = const i64 [] 2\n%neg = const i64 [] -2\n%a = map mod %x %pos\n%b = map mod %x %neg\n%c = map gt %x %pos\n%d = cast f32 %c\n%e = select %c %a %b\n%f = const f32 [8] -1.75 -0.5 0.5 1.75 2.25 3.5 4.75 5.0\n%g = cast i64 %f\noutput %a\noutput %b\noutput %c\noutput %d\noutput %e\noutput %g\noutput %neg\n").unwrap();
    let inputs = HashMap::from([("x".into(), vec![-3., -2., -1., 0., 1., 2., 3., 4.])]);
    let want = eval::run(&p, &inputs).unwrap();
    assert_eq!(want[0], vec![1., 0., 1., 0., 1., 0., 1., 0.]);
    assert_eq!(want[1], vec![-1., 0., -1., 0., -1., 0., -1., 0.]);
    let dir = std::env::temp_dir().join(format!("xir-cuda-test-{}", std::process::id()));
    fs::create_dir_all(&dir).unwrap();
    let src = dir.join("test.cpp");
    let exe = dir.join("test");
    fs::write(&src, cuda::emit(&p, &inputs, &want).unwrap()).unwrap();
    let built = Command::new("c++")
        .args(["-std=c++17", "-O2", "-Wall", "-Werror", "-DXIR_CPU_ONLY"])
        .arg(&src)
        .arg("-o")
        .arg(&exe)
        .output()
        .expect("a C++ compiler is required for the CUDA emitter test");
    assert!(
        built.status.success(),
        "{}",
        String::from_utf8_lossy(&built.stderr)
    );
    let run = Command::new(&exe).output().unwrap();
    assert!(
        run.status.success(),
        "{}",
        String::from_utf8_lossy(&run.stdout)
    );
    // A wrong oracle must make the executable fail, rather than just print it.
    let mut wrong = want.clone();
    wrong[0][0] = 0.;
    fs::write(&src, cuda::emit(&p, &inputs, &wrong).unwrap()).unwrap();
    assert!(Command::new("c++")
        .args(["-DXIR_CPU_ONLY"])
        .arg(&src)
        .arg("-o")
        .arg(&exe)
        .status()
        .unwrap()
        .success());
    assert!(!Command::new(&exe).output().unwrap().status.success());
    fs::remove_dir_all(dir).unwrap();
}

#[test]
fn cuda_refuses_reductions() {
    let p = ir::parse("%x = const f32 [2] 1 2\n%s = reduce add %x\noutput %s\n").unwrap();
    assert!(cuda::emit(&p, &HashMap::new(), &[vec![3.]])
        .unwrap_err()
        .contains("no reductions"));
}
