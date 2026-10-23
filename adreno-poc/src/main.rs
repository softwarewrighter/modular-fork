fn main() {
    let result = (|| {
        let args: Vec<_> = std::env::args().skip(1).collect();
        let counts = match args.as_slice() {
            [] => vec![1024, 4096, 16384, 65536, 262144, 1048576],
            [flag, count] if flag == "--count" => {
                vec![count.parse::<usize>().map_err(|e| e.to_string())?]
            }
            _ => return Err("usage: adreno-vk [--count 1..1048576]".into()),
        };
        for n in counts {
            adreno_vk::run_vector_add(n)?;
        }
        Ok::<_, String>(())
    })();
    if let Err(err) = result {
        eprintln!("ERROR: {err}");
        std::process::exit(1);
    }
}
