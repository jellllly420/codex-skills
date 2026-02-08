#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <command> [args...]" >&2
  exit 2
fi

workspace_root=""
if command -v git >/dev/null 2>&1; then
  if workspace_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
  else
    workspace_root="$(pwd)"
  fi
else
  workspace_root="$(pwd)"
fi

if command -v realpath >/dev/null 2>&1; then
  workspace_root="$(realpath "$workspace_root")"
else
  workspace_root="$(cd "$workspace_root" && pwd -P)"
fi

if ! command -v devcontainer >/dev/null 2>&1; then
  echo "Error: devcontainer CLI not found on PATH." >&2
  exit 127
fi

devcontainer up --workspace-folder "$workspace_root"
devcontainer exec --workspace-folder "$workspace_root" "$@"
