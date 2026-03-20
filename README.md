Build Environment
=================

Docker image for generic build steps. **Not for deployments** — use this image only in build stages of a multi-stage Dockerfile.

The image is based on [mwaeckerlin/very-base](https://github.com/mwaeckerlin/very-base) and includes often needed development tools.

Security
--------

The image uses a `${BUILD_USER}` (coder) for building and a separate `${RUN_USER}` for running the application, so the runtime user cannot overwrite files owned by the build user. Security is key. Additional useful variables are available from the upper base image [mwaeckerlin/scratch](https://github.com/mwaeckerlin/scratch).

Example
-------

Use as a build stage in a multi-stage Dockerfile:

```Dockerfile
FROM mwaeckerlin/build as build
ADD --chown=${BUILD_USER} . .
RUN make

FROM mwaeckerlin/scratch as production
COPY --from=build /app/output /app/output
```

See also: [mwaeckerlin/nodejs-build](https://github.com/mwaeckerlin/nodejs-build)
