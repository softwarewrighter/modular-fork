# Slides: X_eTaL and Mojo on the Adreno 702 (2026-10-23)

The source of the talk Mike Wright gave on the day's work: sixteen
slides, one HTML file each under `slides/`, in the order `deck.json`
lists. Each file is one `<section>` on a 1920 x 1080 canvas with inline
styles, speaker notes in a trailing `<aside>`. Nothing here is built;
the files are the deck's own data as published.

| Slide | What it shows |
| ----- | ------------- |
| cover | Title, author, date |
| board | The UNO Q: QRB2210, four Cortex-A53, Adreno 702, 1.7 GiB, Debian 13.1, Mesa 25.2.6 |
| question | What it takes to run parallel code on this GPU from Mojo and from X_eTaL |
| plan | The day's six steps with commit times, 08:58 to 14:25 Pacific |
| inventory | Turnip (Vulkan 1.0) and rusticl (OpenCL 3.0, C 1.2) both list the physical Adreno; OpenCL first |
| path-xetal | X_eTaL source to Core, XIR, OpenCL C, SPIR-V, NIR, IR3, Adreno shader |
| source-xir | threshold.xtl as typed and as the editor renders it, in JuliaMono |
| kernel | The Float path of threshold.xir beside the generated fused OpenCL kernel |
| results-xetal | Five programs, 71 outputs, all agree; the work-group 128 schedule |
| metal | Eight Freedreno IR3 instructions read against the source |
| mojo-problem | No Adreno target, no compiler on the board, SIGILL; object cross-build, exported C ABI, Rust bridge |
| mojo-source | threshold.mojo, condensed |
| mojo-results | 24 of 24 agree with two oracles; the planted error caught |
| boundary | Established versus not established |
| next | The nine remaining saga steps |
| links | Where everything is |

The deck is published as a private page at
https://claude.ai/artifact/38GHd98m2sKJyvXZWcGamE; its Share menu
exports PowerPoint and PDF. The PDF export is committed here as
`xetal-and-mojo-on-the-adreno-702.pdf` (16 pages, slides as pictures
with a text layer, 4.8 MB), the one binary in this directory, so the
talk can be read without the page. The PowerPoint export is not.
The typefaces are IBM Plex Sans and JetBrains Mono from Google Fonts,
and JuliaMono Regular uploaded to the page for the code blocks, because
it carries the combining underline and the raised letters X_eTaL's
decorated form needs. The font file is not committed either; `deck.json`
names it by the page's asset id.
