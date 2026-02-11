---
name: devcontainer-create
description: 'Create a new `.devcontainer/devcontainer.json` for repositories that do not already have one. Do not modify existing devcontainer configs unless explicitly requested.'
---

# Devcontainer Create

Create a working Dev Container configuration in one pass, then optionally propose performance improvements as a second pass.

## Scope

- Create a new `.devcontainer/devcontainer.json` only when no devcontainer config already exists.
- Do not modify existing devcontainer configs unless the user explicitly asks.

## Workflow

1. Resolve the workspace root (prefer git top-level).
2. Check for existing config in these locations:
- `.devcontainer/devcontainer.json`
- `devcontainer.json` at workspace root
- nested `.devcontainer/**/devcontainer.json`
3. If any config already exists, stop and report that this skill does not modify existing configs unless explicitly requested.
4. Determine the repository basename (for example `linux`, `unsafe_visualizer`).
5. Check tuned presets in `references/presets/` using this priority:
- `references/presets/<repo>.devcontainer.json`
- `references/presets/<repo>.devcontainer.jsonc`
- `references/presets/<repo>.json`
6. If a preset is found, use it as the primary baseline and apply only the safety normalization rules in this skill.
7. If no preset is found, detect project type/complexity from repository signals (`Cargo.toml`, `package.json`, `pyproject.toml`, `go.mod`, `Makefile`, docs) and build config from the default rules.
8. Write `.devcontainer/devcontainer.json`.
9. Return the created config plus optional optimization ideas (separate from the working config).

## Preset Discovery Behavior

- Always re-read `references/presets/` from disk on each invocation.
- Do not assume cached preset content across turns.
- Treat user-added or user-edited preset files as the latest source of truth.

## Preset File Format

- Accept JSON (`.json`) and JSONC-like (`.jsonc`, comments/trailing commas).
- Use preset naming based on repository basename.
- Example: `references/presets/linux.devcontainer.jsonc` for repo `linux`.

## Baseline Rules

Apply these defaults unless the user overrides them or a tuned preset explicitly sets alternatives:

- Set `name` to `<repo>-dev`.
- Set `workspaceFolder` to the exact value `/workspaces/${localWorkspaceFolderBasename}`.
- Do not hardcode `workspaceFolder` as `/workspaces/<repo-name>`.
- Set `runArgs` to include `--network=host`.
- Prefer Debian-based images.
- For MCR images, set `remoteUser: "vscode"`.
- For MCR images, set `containerEnv.SHELL: "/bin/zsh"`.
- Keep the initial config reliability-first.
- Do not add cache mounts by default.

## Safety Normalization Rules

Apply these checks before returning output, including preset-based output:

- Verify `workspaceFolder` is `/workspaces/${localWorkspaceFolderBasename}`.
- If `remoteUser` is non-root (for example `vscode`), use `sudo` for privileged setup commands.
- If apt commands are used with non-root user, ensure this pattern:
- `sudo apt-get update`
- `sudo apt-get install -y --no-install-recommends ...`
- cleanup with `sudo apt-get clean` and `sudo rm -rf /var/lib/apt/lists/*`

## Image Selection (No Preset)

Use this priority order:

1. If project docs explicitly require an official project dev image, use that image.
2. For single-language or simple multi-language projects, prefer official MCR language images with `:latest`.
3. For complex multi-language projects or special toolchain-heavy setups (for example Linux kernel-style workflows), use `mcr.microsoft.com/devcontainers/base:trixie` and install toolchains in `postCreateCommand`.

## Post-Create Command Rules (No Preset)

- Include only toolchain/setup steps that are clearly required by the project.
- Avoid speculative extras.

## Cargo / Toolchain Path Safety

Do not assume host-like paths for preinstalled toolchains inside MCR images.

- Rust images may use `/usr/local/cargo` instead of `~/.cargo`.
- Before adding any mount/env/path overrides for tool caches, verify actual paths in the image.
- Default behavior: skip cache mounts unless explicitly requested.

## Container Naming Clarification

`name` in `devcontainer.json` is a Dev Container label, not a guaranteed Docker container name.

- Do not force Docker container names by default.
- If the user explicitly asks for deterministic Docker names, add `runArgs: ["--name=<repo>-dev"]` and warn about collision risk when multiple instances exist.

## Output Contract

When creating config:

1. Provide the full `devcontainer.json` content.
2. State why the chosen baseline (preset or generated) is minimal but sufficient.
3. Provide optional, clearly separated optimization ideas.
4. Verify safety normalization rules before returning output.

For optional optimization ideas, see:
- `references/performance-options.md`

For reusable config patterns, see:
- `references/templates.md`

## Handoff to Devcontainer Exec

After creating the config, route toolchain/build/test commands through `$devcontainer-exec` when that skill is available.

Keep this as an execution behavior of Codex, not project code or docs.
