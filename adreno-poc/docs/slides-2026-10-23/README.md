# Slides: X_eTaL and Mojo on the Adreno 702 (2026-10-23)

The source of the talk Mike Wright gave on the day's work: twenty-three
slides, one HTML file each under `slides/`, in the order `deck.json`
lists. Each file is one `<section>` on a 1920 x 1080 canvas with inline
styles, speaker notes in a trailing `<aside>`. Nothing here is built;
the files are the deck's own data as published.

| Slide | What it shows |
| ----- | ------------- |
| cover | Title, author, date |
| board | The UNO Q: QRB2210, four Cortex-A53, Adreno 702, 1.7 GiB, Debian 13.1, Mesa 25.2.6 |
| question | What it takes to run parallel code on this GPU from Mojo and from X_eTaL |
| plan | The day's seven steps with commit times, 08:58 to 16:49 Pacific |
| inventory | Turnip (Vulkan 1.0) and rusticl (OpenCL 3.0, C 1.2) both list the physical Adreno; OpenCL first |
| path-xetal | X_eTaL source to Core, XIR, OpenCL C, SPIR-V, NIR, IR3, Adreno shader |
| source-xir | threshold.xtl as typed and as the editor renders it, in JuliaMono |
| kernel | The Float path of threshold.xir beside the generated fused OpenCL kernel |
| results-xetal | Five programs, 71 outputs, all agree; the work-group 128 schedule |
| metal | Eight Freedreno IR3 instructions read against the source |
| mojo-problem | No Adreno target, no compiler on the board, SIGILL; object cross-build, exported C ABI, Rust bridge |
| mojo-source | threshold.mojo, the whole file |
| mojo-results | 24 of 24 agree with two oracles; the planted error caught |
| two-sources | X_eTaL's Accel threshold and relu beside the ordinary Mojo kernel |
| mojo-whole-1 | The whole of mojo/activation_gpu.mojo, lines 1 to 34: header, imports, kernel |
| mojo-whole-2 | Lines 35 to 83: the host and the self-check |
| steps-all | Every step: X_eTaL to the Adreno; Mojo to Metal, CUDA and, through the retarget, the Adreno |
| retarget | The seven NVPTX-to-OpenCL-SPIR-V substitutions, llc, SPIR-V 1.0 |
| three-gpus | One Mojo kernel on M1 Max, RTX 5060 Ti and Adreno 702, 24 of 24 each |
| adreno-both | The Adreno instructions from X_eTaL and from Mojo, side by side |
| boundary | Established versus not established |
| next | Mojo, Vulkan and measurement work that follows |
| links | Where everything is |

The deck is published as a private page at
https://claude.ai/artifact/38GHd98m2sKJyvXZWcGamE; its Share menu
exports PowerPoint and PDF. The PDF export is committed here as
`xetal-and-mojo-on-the-adreno-702.pdf` (the first 16-slide version, slides as
pictures with a text layer, 4.8 MB; re-export for the 23-slide deck), the one binary in this directory, so the
talk can be read without the page. The PowerPoint export is not.
The typefaces are IBM Plex Sans and JetBrains Mono from Google Fonts,
and JuliaMono Regular uploaded to the page for the code blocks, because
it carries the combining underline and the raised letters X_eTaL's
decorated form needs. The font file is not committed either; `deck.json`
names it by the page's asset id.
