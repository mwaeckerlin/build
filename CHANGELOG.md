# Changelog

- 2026-07-17 **1.1.0**
    - Command lookup hardened: system commands now always win over tools installed by npm packages — a malicious or mistyped package can no longer shadow a system command during a build
        - the convenience lookup of locally installed Node tools still works, it just comes last
    - Removed a duplicate package from the default package list
    - Image build no longer emits warnings (modernized instruction format)
