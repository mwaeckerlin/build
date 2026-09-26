# Build Environment

Docker image for generic build steps. **Not for deployments** — use this image only in build stages of a multi-stage Dockerfile.

The image is based on [mwaeckerlin/very-base](https://github.com/mwaeckerlin/very-base) and includes often needed development tools: C and C++ tool chain with autotools, git, gpg, curl, Node.js with npm and yarn, Python with pip, PHP, Ruby and upx. The build argument `PACKAGES` replaces that list. The image is published for `linux/amd64` and `linux/arm64`.

## Security

The image uses a `${BUILD_USER}` (coder) for building and a separate `${RUN_USER}` for running the application, so the runtime user cannot overwrite files owned by the build user. Security is key. Additional useful variables are available from the upper base image [mwaeckerlin/scratch](https://github.com/mwaeckerlin/scratch).

Trade-off: `PATH` contains the relative entries `node_modules/.bin` and `/app/node_modules/.bin` so that locally installed Node tools can be called directly in build steps. They are listed *after* the system paths, so a binary installed by an npm package can never shadow a system command.

## Example

Use as a build stage in a multi-stage Dockerfile:

```Dockerfile
FROM mwaeckerlin/build AS build
ADD --chown=${BUILD_USER} . .
RUN make

FROM mwaeckerlin/scratch AS production
COPY --from=build /app/output /app/output
```

See also: [mwaeckerlin/nodejs-build](https://github.com/mwaeckerlin/nodejs-build)

## Development

```bash
$ npm run build
$ npm test
```

`npm test` checks the feature register ([FEATURES.md](FEATURES.md), [TESTS.md](TESTS.md)) and runs the image contract `tests/config-contract.sh`. The image is built and published by the reusable workflow of [mwaeckerlin/scratch](https://github.com/mwaeckerlin/scratch#publishing-on-docker-hub).
