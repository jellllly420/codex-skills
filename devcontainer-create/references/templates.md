# Devcontainer Templates

Use these templates as starting points and customize only what the project needs.

Important: keep `workspaceFolder` as `/workspaces/${localWorkspaceFolderBasename}`. Do not replace it with a literal repo name.

## Tuned presets for known projects

For known complex projects, place tuned configs in:

- `references/presets/<repo>.devcontainer.json`
- `references/presets/<repo>.devcontainer.jsonc`
- `references/presets/<repo>.json`

These presets are loaded first (exact repo basename match) and can override generic templates.

## 1) MCR language image (single/simple projects)

```json
{
  "name": "<repo>-dev",
  "image": "mcr.microsoft.com/devcontainers/<language>:latest",
  "remoteUser": "vscode",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  "runArgs": [
    "--network=host"
  ],
  "containerEnv": {
    "SHELL": "/bin/zsh"
  }
}
```

## 2) Base trixie image (complex/toolchain-heavy projects)

```json
{
  "name": "<repo>-dev",
  "image": "mcr.microsoft.com/devcontainers/base:trixie",
  "remoteUser": "vscode",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  "runArgs": [
    "--network=host"
  ],
  "containerEnv": {
    "SHELL": "/bin/zsh"
  },
  "postCreateCommand": "sudo apt-get update && sudo apt-get install -y --no-install-recommends <packages> && sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*"
}
```

## 3) Optional deterministic Docker container name (only on explicit request)

```json
{
  "runArgs": [
    "--network=host",
    "--name=<repo>-dev"
  ]
}
```

Warning: fixed `--name` can fail when another container with the same name already exists.
