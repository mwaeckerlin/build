Build Environment
=================

Docker image for generic build steps. NOT FOR DEPLOYMENTS — use this image only in build stages of a multi-stage Dockerfile.

The image is based on [mwaeckerlin/very-base](https://github.com/mwaeckerlin/very-base) and includes the following tools:

- `git`
- `python3`
- `g++`
- `make`
- `gpg`

Example
-------

Use as a build stage in a multi-stage Dockerfile:

```Dockerfile
FROM mwaeckerlin/build as build
ADD --chown=somebody . .
RUN make

FROM scratch as production
COPY --from=build /app/output /app/output
```

See also: [mwaeckerlin/nodejs-build](https://github.com/mwaeckerlin/nodejs-build)
