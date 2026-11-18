# Changelog

- 2026-11-19 **1.1.2**
    - Node.js 26, the current LTS, from the Alpine package `nodejs-current`; the image had Node.js 24.22 from the package `nodejs`
    - The architecture of the image is documented, with diagrams, and a test checks that the build argument `PACKAGES` replaces the package list

- 2026-09-26 **1.1.1**
    - The image is published for amd64 and arm64 under one tag, built and published automatically on every change and every week

- 2026-07-17 **1.1.0**
    - Command lookup hardened: system commands now always win over tools installed by npm packages — a malicious or mistyped package can no longer shadow a system command during a build
        - the convenience lookup of locally installed Node tools still works, it just comes last
    - Removed a duplicate package from the default package list
    - Image build no longer emits warnings (modernized instruction format)
