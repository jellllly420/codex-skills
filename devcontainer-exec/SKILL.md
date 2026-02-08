---
name: devcontainer-exec
description: Run toolchain commands in a Dev Container when devcontainer.json exists, but keep this behavior as a Codex-only execution detail (do not bake container awareness into project code/config/docs unless explicitly requested).
---

# Devcontainer Exec

Apply one execution policy for Codex:
if this project has a Dev Container configuration, run toolchain commands in that container.

## Core Principle (Important)

This skill is for Codex command execution only.

- Do not make the target project aware of Dev Container usage.
- Do not copy or vend helper scripts into the project.
- Do not add project wrappers whose purpose is to route through Dev Containers.
- Do not add container-specific deployment assumptions to app code.
- Do not edit project docs/config to mention Dev Container workflow unless the user explicitly asks.

The project should remain environment-agnostic. If the same toolchain exists on host, it should run there unchanged.

## Decision Procedure

1. Determine workspace root (prefer git top-level; otherwise current directory).
2. Detect Dev Container config in typical locations:
- `.devcontainer/devcontainer.json`
- `devcontainer.json` at workspace root
- any `devcontainer.json` within `.devcontainer/` subdirectories
3. If present:
- Run toolchain/build/test/lint/format/package-manager commands via:
  `~/.codex/skills/devcontainer-exec/scripts/in_devcontainer.sh ...`
- Do not run those commands directly on host.
4. If absent:
- Run commands normally on host.

## Command Scope

Treat these as toolchain commands (route through helper when Dev Container config exists):

- language toolchains (`cargo`, `go`, `npm`, `pnpm`, `yarn`, `pip`, `poetry`, `mvn`, `gradle`, etc.)
- build/test/lint/format commands (`make test`, `pytest`, `ruff`, `eslint`, `prettier`, `clang-tidy`, `cmake --build`, etc.)

## Usage

Use the global helper directly:

```bash
~/.codex/skills/devcontainer-exec/scripts/in_devcontainer.sh <command> [args...]
```

Examples:

```bash
~/.codex/skills/devcontainer-exec/scripts/in_devcontainer.sh cargo test
~/.codex/skills/devcontainer-exec/scripts/in_devcontainer.sh make test
~/.codex/skills/devcontainer-exec/scripts/in_devcontainer.sh npm test
```

## Minimal Notes

- Requires Dev Containers CLI (`devcontainer`) on PATH.
- Requires a working container runtime (for example Docker).
