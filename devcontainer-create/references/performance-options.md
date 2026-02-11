# Optional Performance Ideas

Apply only after a working config exists.

## Safe options to consider

- Add language/server tooling only when repeatedly used (reduce startup overhead).
- Use project-appropriate caches only when they are confirmed beneficial.
- For heavy C/C++ builds, consider `ccache` plus a dedicated volume (as in Linux workflows).
- For very heavy setup, prebuild a custom image instead of long `postCreateCommand` installs.

## Cache-mount caution

Avoid cache mounts by default. If enabling them:

1. Verify the actual tool cache path used by the selected image.
2. Ensure writable ownership for `remoteUser` inside the container.
3. Validate with real tool commands before recommending as a default pattern.

Example ownership fix pattern (only when needed):

```bash
sudo mkdir -p <cache-path> && sudo chown -R vscode:vscode <cache-path>
```

Use this pattern carefully and only on paths confirmed safe for ownership changes.
