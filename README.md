<!-- rumdl-disable-file MD033 MD041 MD075 -->

# softwarewrighter fork: X_eTaL array code on GPUs through Mojo

This fork of [modular/modular](https://github.com/modular/modular) adds
[`rust-demo/`](rust-demo/), on the `experimental` branch: array code from
the [X_eTaL](https://github.com/softwarewrighter/X_eTaL) ecosystem, run on
Apple and NVIDIA GPUs through a Mojo library instead of OpenCL. The story
is on the blog:
[Array Languages #10: X_eTaL on Metal and CUDA, Through Mojo](https://blog.softwarewrighter.com/2026/10/16/array-languages-xetal-mojo-metal/),
and the follow-up reads one kernel down every toolchain:
[Rabbit-hole #8: From X_eTaL to the Metal, One Kernel Down Every GPU Toolchain](https://blog.softwarewrighter.com/2026/10/21/rabbit-hole-xetal-to-the-metal/).

[X_eTaL-gpu](https://github.com/softwarewrighter/X_eTaL-gpu) lowers X_eTaL
array programs to an accelerator IR (XIR) and emits OpenCL C for it. Here a
small Rust tool reads programs in XIR's text form, writes the Mojo a
person would write for the same GPU work, builds it with
`mojo build --emit shared-lib` into a library with a C interface, loads it,
and runs it. Mojo picks the GPU: **Metal** on the Apple M1 Max, **CUDA** on
the NVIDIA RTX 5060 Ti. The same Rust, the same five programs and the same
generated Mojo ran on both, with no change for NVIDIA, and every result is
checked against a Rust reference evaluator.

Since 2026-10-16 the program can come from X_eTaL source with nothing
written by hand: X_eTaL-gpu's `xetal-gpu lower` turns an `.xtl` program
into XIR, this tool turns the XIR into Mojo, and the GPU's answer is
checked against what X_eTaL's own evaluator printed for the source. Five
of X_eTaL-gpu's thirteen Accel demos lower into the subset this tool
takes (vectors of one length, f32 and ints, fused maps, whole-array
reductions) and all five agree exactly on the M1 Max and on the RTX 5060 Ti. The other eight
need axes, matrices and gathers, which X_eTaL-gpu's saga gpu-mojo adds
as it ports this emitter into its own `components/mojo`. X_eTaL-gpu's
OpenCL path is not replaced; Mojo is a second backend beside it.

## Links

| What | Where |
| ---- | ----- |
| The demo | [rust-demo/README.md](rust-demo/README.md) |
| Results, per device | [rust-demo/doc/results.md](rust-demo/doc/results.md) |
| RTX 5060 Ti evidence (raw logs, 2026-10-16) | [five programs](rust-demo/doc/evidence/rtx5060-20261016/) · [all ten, with the X_eTaL-lowered five](rust-demo/doc/evidence/rtx5060-20261016-ten-programs/) · [what they establish](rust-demo/doc/rtx5060-handoff.md) |
| One program, top down: X_eTaL → Core → XIR → Mojo → PTX, AIR, AMDGCN, arm64 | [rust-demo/doc/top-down.md](rust-demo/doc/top-down.md) · handoffs: [CUDA](rust-demo/doc/cuda-blog-handoff.md) · [Metal](rust-demo/doc/metal-blog-handoff.md) · [AMD](rust-demo/doc/amd-blog-handoff.md) · [CPU](rust-demo/doc/cpu-blog-handoff.md) |
| Proving the GPU ran it | [rust-demo/doc/proving-gpu-execution.md](rust-demo/doc/proving-gpu-execution.md) |
| Mojo as a C-callable library | [rust-demo/doc/mojo-as-a-library.md](rust-demo/doc/mojo-as-a-library.md) |
| Linux and NVIDIA setup | [rust-demo/doc/porting-arch-rtx5060.md](rust-demo/doc/porting-arch-rtx5060.md) |
| Older NVIDIA cards | [rust-demo/doc/older-gpus.md](rust-demo/doc/older-gpus.md) |
| X_eTaL, X_eTaL-gpu, X_eTaL-ML | [X_eTaL](https://github.com/softwarewrighter/X_eTaL) · [X_eTaL-gpu](https://github.com/softwarewrighter/X_eTaL-gpu) · [X_eTaL-ML](https://github.com/softwarewrighter/X_eTaL-ML) |
| This work, on the blog | [Array Languages #10: X_eTaL on Metal and CUDA, Through Mojo](https://blog.softwarewrighter.com/2026/10/16/array-languages-xetal-mojo-metal/) |
| The GPU deep dive, on the blog | [Rabbit-hole #8: From X_eTaL to the Metal, One Kernel Down Every GPU Toolchain](https://blog.softwarewrighter.com/2026/10/21/rabbit-hole-xetal-to-the-metal/) |
| The OpenCL work, on the blog | [Array Programs on GPUs Old and New](https://blog.softwarewrighter.com/2026/10/13/array-languages-xetal-gpu/) |
| Upstream | [modular/modular](https://github.com/modular/modular) · [Mojo docs](https://mojolang.org/docs/) · [GPU compatibility](docs/max/packages.mdx) |

## Results

Mojo 1.2.0.dev2026101305 on both machines. All five programs agree with
the reference: elementwise results exactly, reductions exactly or within
the float tolerance (the GPU sums as a tree, the reference as a right
fold).

| Program | What it exercises | Apple M1 Max, Metal | RTX 5060 Ti, CUDA |
| ------- | ----------------- | ------------------- | ----------------- |
| saxpy | fused elementwise | exact | exact |
| threshold | comparisons, bools, select | exact | exact |
| reduce | sum, max, min (two-pass trees) | exact | exact |
| softmax | two stages split by reductions | within 5e-7 | within 4.77e-7 |
| stats | mean and variance | within 6.6e-6 | within 6.56e-6 |

From X_eTaL source, lowered by `xetal-gpu` and checked against X_eTaL's
evaluator as well (the device gate runs these too):

| Accel demo (`.xtl`) | Lowered to | Apple M1 Max, Metal | RTX 5060 Ti, CUDA |
| ------------------- | ---------- | ------------------- | ----------------- |
| saxpy | 1 fused kernel | exact | exact |
| threshold | comparisons, cast, int `mod` | exact | exact |
| reduce-sum | int and float reductions | exact | exact |
| pipeline | 2 kernels, 2 reductions | exact | exact |
| vector-add | int and float kernels | exact | exact |

Both columns are from 2026-10-16; the Arch run is at commit f95c7ba386
with the lowered XIR pinned to X_eTaL-gpu 38bae5c, its logs under
[rust-demo/doc/evidence/rtx5060-20261016-ten-programs/](rust-demo/doc/evidence/rtx5060-20261016-ten-programs/).

The device dump shows Metal AIR (`air64-apple-macosx26.0.0`) on the Mac
and PTX for `sm_120a` on the NVIDIA card. Build and run times per program
and per device are in [rust-demo/doc/results.md](rust-demo/doc/results.md);
they are single runs including the first-use kernel compile, not
benchmarks.

## How Mojo reaches each GPU

- **Apple silicon:** Mojo compiles kernels to Metal AIR and runs them
  through Metal (needs Xcode's Metal toolchain). No OpenCL.
- **NVIDIA:** Mojo compiles kernels with its own LLVM backend to PTX,
  assembles the PTX to machine code with `ptxas` (its bundled one needs
  driver 580 or newer; `MODULAR_NVPTX_COMPILER_PATH` names another), and
  loads it through the CUDA driver (`libcuda`). No CUDA toolkit, `nvcc` or
  OpenCL is involved.
- **AMD:** through ROCm (HIP); not tried here.

## The NVIDIA cards, Mojo or OpenCL

Modular lists the RTX 30, 40 and 50 series (Ampere, Ada, Blackwell) and
Turing as compatible for Mojo development, with driver 580 or newer.
Mojo's compiler also has targets for Maxwell and Pascal, which the
docs do not list as supported; Kepler has none. Older GPUs will be
supported through X_eTaL-gpu's OpenCL path if Mojo cannot be configured
for them.

| Card | Architecture | Mojo | Plan |
| ---- | ------------ | ---- | ---- |
| RTX 5060 Ti 16 GB | Blackwell, sm_120 | listed; **verified 2026-10-16** | Mojo |
| RTX 4070 Laptop 8 GB | Ada, sm_89 | listed | Mojo |
| RTX 3090 24 GB, RTX 3060 12 GB, RTX 3060 Laptop | Ampere, sm_86 | listed | Mojo |
| A2 16 GB | Ampere, sm_86 | architecture listed, card not | Mojo, to confirm |
| GTX 1660 Super | Turing, sm_75 | architecture listed, card not | Mojo, to confirm |
| Tesla P100, P4 | Pascal, sm_60, sm_61 | compiler target only | try Mojo, else OpenCL |
| Tesla M40, M10 | Maxwell, sm_52, sm_50 | compiler target only | try Mojo, else OpenCL |
| Tesla K80, Quadro K4200 | Kepler, sm_37, sm_30 | none | OpenCL |

## Quick start

```sh
git switch experimental
cd rust-demo
scripts/setup.sh      # venv with the pinned Mojo and MAX nightly; checks the GPU toolchain
just gate             # build, run and check all ten programs on this machine's GPU
just capture          # versions, tests, runs and assembly into work/results-<time>/
just xtl ../../X_eTaL-gpu/libs/Accel/demos/saxpy.xtl   # X_eTaL source, lowered, Mojo, GPU, checked
```

---

*Below: the original Modular README, unchanged.*

<div align="center">
    <img src="https://modular-assets.s3.us-east-1.amazonaws.com/images/modular-banner-github.png">

[About Modular] | [MAX docs] | [Mojo docs] | [Contributing]

</div>

---

# Modular Platform

This repo hosts open-source components of the Modular Platform,
a unified platform for AI development and deployment,
including the **MAX Framework**🧑‍🚀 and the **Mojo Language**🔥.

## Get started

To get started with the Modular Platform and serve a model using the MAX
framework, see
[the MAX quickstart guide](https://max.modular.com/get-started).

To get started with the Mojo language, see
[the Mojo quickstart guide](https://mojolang.org/docs/manual/quickstart/).

## About the repo

We're constantly open-sourcing more of the Modular Platform and you can find
all of it in here.

The main components include:

- Mojo compiler: [/Mojo](/Mojo)
- Mojo standard library: [/Mojo/stdlib](/Mojo/stdlib)
- MAX accelerator library: [/max/kernels](/max/kernels)
- MAX inference server: [/max/python/max/serve](/max/python/max/serve)
  (OpenAI-compatible endpoint)
- MAX model pipelines: [/max/python/max/pipelines](/max/python/max/pipelines)
  (Python-based graphs)
- Code examples: [/max/examples](/max/examples) +
  [/Mojo/examples](/Mojo/examples)

## Contribute

We accept contributions to the [Mojo standard library](/Mojo/stdlib), [MAX
accelerator library](./max/kernels), [MAX model
architectures](/max/python/max/pipelines/architectures), code examples, Mojo
docs, and more. We aren't accepting contributions to the Mojo compiler yet.

First, please read the [Contribution Guide](./CONTRIBUTING.md), and then refer
to the following documentation about how to develop in the repo:

- [`/max/docs`](/max/docs): Docs for developers working in the MAX framework
  codebase.
- [`/Mojo/docs/stdlib`](/Mojo/docs/stdlib): Docs for developers working in the
  Mojo standard library.

We also welcome your bug reports. If you have a bug, please [file an issue
here](https://github.com/modular/modular/issues/new/choose).

## License

This repository and its contributions are licensed under the Apache License v2.0
with LLVM Exceptions. See [LICENSE](LICENSE).

MAX usage and distribution are licensed under the
[Modular Community License](https://www.modular.com/legal/community).

### Third party licenses

You are entirely responsible for checking and validating the licenses of third
parties (for example, Hugging Face) for related software and libraries that are
downloaded.

## Community & Events

Get help from community members, tune in for a community meeting, or join a
local meetup.

| Channel               | Link                                            |
|-----------------------|-------------------------------------------------|
| 💬 Discord            | [discord.gg/modular][discord]                   |
| 💬 Forum              | [forum.modular.com][forum]                      |
| 📅 Meetup Group       | [meetup.com/modular-meetup-group][meetup-group] |
| 🎦 Community Meetings | [Upcoming community calls][public-com-meet-doc] |
| 📺 YouTube            | [youtube.com/@modularinc][youtube]              |

**Upcoming events** will be posted on our [Meetup page][meetup-group] and
[Discord][discord]. Community meeting recordings will be posted on our
[YouTube][youtube].

## Thanks to our contributors

<a href="https://github.com/modular/modular/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=modular/modular" />
</a>

<!-- Link references -->

<!-- Header navigation links -->
[About Modular]: https://www.modular.com/
[MAX docs]: https://max.modular.com/
[Contributing]: ./CONTRIBUTING.md
[Mojo docs]: https://mojolang.org/docs/

<!-- Community & Events links -->
[discord]: https://discord.gg/modular
[forum]: https://forum.modular.com/
[meetup-group]: https://www.meetup.com/modular-meetup-group/
[youtube]: https://www.youtube.com/@modularinc
[public-com-meet-doc]: https://modul.ar/community-meeting-doc
