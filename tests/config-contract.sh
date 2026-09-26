#!/usr/bin/env bash
# Config contract: the generic build image carries its tools and builds as the
# unprivileged build user.
#
# `--pull=never` keeps docker from silently pulling a stale image when the
# local build is missing.
#
# Usage: tests/config-contract.sh IMAGE

set -uo pipefail

IMAGE="${1:?usage: tests/config-contract.sh IMAGE}"

PASS=0
FAIL=0
declare -a FAILED_NAMES

_pass() { PASS=$((PASS + 1)); echo "  PASS  $1"; }
_fail() { FAIL=$((FAIL + 1)); FAILED_NAMES+=("$1"); echo "  FAIL  $1: $2"; }

_run() { docker run --rm --pull=never "${IMAGE}" "$@"; }

echo "==> Config contract: generic build image"

if ! docker image inspect "${IMAGE}" > /dev/null 2>&1; then
    _fail "${IMAGE}_image_exists" "image not built — run 'npm run build' first"
else
    for tool in bash gcc g++ make autoconf automake libtool git gpg curl node npm yarn python3 pip php ruby upx bzip2; do
        if _run sh -c "command -v ${tool}" > /dev/null 2>&1; then
            _pass "tool_${tool}"
        else
            _fail "tool_${tool}" "not installed"
        fi
    done

    for header in openssl/ssl.h zlib.h ffi.h readline/readline.h; do
        if _run test -f "/usr/include/${header}" > /dev/null 2>&1; then
            _pass "header_${header%%[/.]*}"
        else
            _fail "header_${header%%[/.]*}" "/usr/include/${header} missing"
        fi
    done

    if _run sh -c 'printf "int main(){return 0;}" > t.c && gcc -o t t.c && ./t' > /dev/null 2>&1; then
        _pass "compiles_in_app"
    else
        _fail "compiles_in_app" "a C program does not compile and run in /app"
    fi

    WHO=$(_run id -un 2>&1)
    if [[ "${WHO}" == "coder" ]]; then
        _pass "builds_as_coder"
    else
        _fail "builds_as_coder" "runs as '${WHO}'"
    fi
    WORKDIR=$(_run pwd 2>&1)
    if [[ "${WORKDIR}" == "/app" ]]; then
        _pass "workdir_app"
    else
        _fail "workdir_app" "working directory is '${WORKDIR}'"
    fi

    SHADOW=$(_run sh -c 'mkdir -p node_modules/.bin && printf "#!/bin/sh\necho shadowed\n" > node_modules/.bin/ls && chmod +x node_modules/.bin/ls && ls /' 2>&1)
    if [[ "${SHADOW}" != *shadowed* ]]; then
        _pass "system_command_wins_over_node_modules"
    else
        _fail "system_command_wins_over_node_modules" "node_modules/.bin/ls shadowed the system ls"
    fi
    LOCAL=$(_run sh -c 'mkdir -p node_modules/.bin && printf "#!/bin/sh\necho local-tool\n" > node_modules/.bin/some-local-tool && chmod +x node_modules/.bin/some-local-tool && some-local-tool' 2>&1)
    if [[ "${LOCAL}" == "local-tool" ]]; then
        _pass "local_node_tool_found"
    else
        _fail "local_node_tool_found" "a tool in node_modules/.bin is not found: '${LOCAL}'"
    fi

    NODE_ENV_VALUE=$(docker image inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "${IMAGE}" | sed -n 's/^NODE_ENV=//p')
    if [[ "${NODE_ENV_VALUE}" == "development" ]]; then
        _pass "node_env_development"
    else
        _fail "node_env_development" "NODE_ENV is '${NODE_ENV_VALUE}'"
    fi
fi

echo ""
echo "==> Config contract results: ${PASS} passed, ${FAIL} failed"
if [[ ${FAIL} -gt 0 ]]; then
    echo "==> Failed contracts: ${FAILED_NAMES[*]}"
    exit 1
fi
