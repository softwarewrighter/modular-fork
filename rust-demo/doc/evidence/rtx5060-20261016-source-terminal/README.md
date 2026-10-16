# Arch source-demo terminal transcript

[`reduce-sum.typescript`](reduce-sum.typescript) is the unmodified terminal
capture of this exact command, run from
`/disk1/github/softwarewrighter/X_eTaL-gpu` on 2026-10-16:

```sh
just run-mojo libs/Accel/demos/reduce-sum.xtl
```

X_eTaL-gpu revision: `4052c9250ef92490150fde2c6c72298dc6b9400b`.
The command exited successfully and reported
`api=cuda;name=NVIDIA GeForce RTX 5060 Ti`, then printed the five outputs.
Its timing line reports build 0.000 ms (cached), run 431.069 ms, and
total 1386.458 ms. This is a source-demo run in X_eTaL-gpu, separate
from the earlier `rust-demo` ten-program verification.

Captured with util-linux `script --quiet --return --command`, with
stdout and stderr attached to a real pseudo-terminal. The file retains
the capture timestamps, command, exit code, ANSI bold escapes from
`just`, and terminal CRLF line endings. No output was reconstructed.
View the terminal formatting with `cat reduce-sum.typescript`.
