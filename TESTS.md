# Tests

Register of all tests, sorted by the [FEATURES.md](FEATURES.md) number each test covers. `npm test` runs everything; the guard `tests/docs-contract.sh` fails when a feature has no test entry here.

## Image contract

- **F1** `tests/config-contract.sh` › tool_bash … tool_bzip2, header_openssl, header_zlib, header_ffi, header_readline, compiles_in_app — every tool and header of the default list is installed, and a C program compiles and runs.
- **F1** `tests/config-contract.sh` › packages_replace_the_list — an image built with `--build-arg PACKAGES=bash` carries bash and no `gcc` of the default list.
- **F1** `tests/config-contract.sh` › node_is_current_lts — `node` has the major version of `NODE_VERSION` in `node:lts-alpine` (regression: 24.22 from the Alpine package `nodejs`, while the LTS was 26).
- **F2** `tests/config-contract.sh` › builds_as_coder, workdir_app, compiles_in_app — build steps run as `coder` in a writable `/app`.
- **F3** `tests/config-contract.sh` › system_command_wins_over_node_modules, local_node_tool_found — a fake `ls` in `node_modules/.bin` does not shadow the system `ls`, and a tool that exists only there is found.
- **F4** `tests/config-contract.sh` › node_env_development — `NODE_ENV` is `development`.

## Workflow contract

- **F5** `tests/workflow-contract.sh` of `mwaeckerlin/scratch` — the reusable workflow selects exactly the images a repository publishes; this repository calls it from `.github/workflows/docker.yml`.
