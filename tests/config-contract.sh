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

    # the build argument PACKAGES replaces the default list: an image built
    # with bash alone carries bash and none of the default tool chain
    CHILD="${IMAGE%%:*}-config-contract-packages"
    if docker build --quiet --build-arg PACKAGES=bash -t "${CHILD}" "$(dirname "$0")/.." > /dev/null 2>&1; then
        CHILD_BASH=$(docker run --rm --pull=never "${CHILD}" sh -c 'command -v bash' 2>&1)
        CHILD_GCC=$(docker run --rm --pull=never "${CHILD}" sh -c 'command -v gcc || echo none' 2>&1)
        docker image rm "${CHILD}" > /dev/null
        if [[ -n "${CHILD_BASH}" && "${CHILD_GCC}" == "none" ]]; then
            _pass "packages_replace_the_list"
        else
            _fail "packages_replace_the_list" "bash: '${CHILD_BASH}', gcc: '${CHILD_GCC}'"
        fi
    else
        _fail "packages_replace_the_list" "the image does not build with PACKAGES=bash"
    fi

    # the node of the official LTS image node:lts-alpine, pulled once
    docker image inspect node:lts-alpine > /dev/null 2>&1 || docker pull -q node:lts-alpine > /dev/null
    LTS=$(docker image inspect --format '{{range .Config.Env}}{{println .}}{{end}}' node:lts-alpine 2>/dev/null | sed -n 's/^NODE_VERSION=//p')
    NODE_VERSION_VALUE=$(_run node -p process.versions.node 2>&1)
    if [[ -n "${LTS}" && "${NODE_VERSION_VALUE}" == "${LTS%%.*}."* ]]; then
        _pass "node_is_current_lts"
    else
        _fail "node_is_current_lts" "node ${NODE_VERSION_VALUE}, LTS «${LTS}» (docker pull node:lts-alpine)"
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
