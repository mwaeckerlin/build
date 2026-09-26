# Features

Numbered register of every feature; a number is never reused. Every feature is covered by tests listed in [TESTS.md](TESTS.md); the guard `tests/docs-contract.sh` fails when a feature has no test.

- **F1 — Generic build tools.** C and C++ tool chain with autotools and libtool, git, gpg, curl, Node.js with npm and yarn, Python with pip, PHP, Ruby, upx and bzip2, plus the development files of OpenSSL, zlib, libffi and readline; the build argument `PACKAGES` replaces the list.
- **F2 — Unprivileged build user.** Build steps run as `coder` in `/app`, which belongs to `coder`; the runtime user `somebody` of the final stage cannot overwrite what the build user produced.
- **F3 — System commands first.** `PATH` lists the system directories before `node_modules/.bin` and `/app/node_modules/.bin`, so a tool installed by an npm package never shadows a system command, and a locally installed Node tool is still found by its name.
- **F4 — Development mode for Node.js.** `NODE_ENV` is `development`, so `npm install` installs the development dependencies a build needs.
- **F5 — Published for amd64 and arm64.** Every push builds the image natively for both architectures and publishes it under one tag on Docker Hub, with the reusable workflow of `mwaeckerlin/scratch`.
