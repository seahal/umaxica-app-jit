#!/usr/bin/env bash
set -euo pipefail

# Fix ownership under /home/jit (dotfiles, caches, tmpfs mounts, etc.).
# Skip the workspace bind mount to avoid traversing the entire project tree.
sudo chown 1000:1000 /home/jit
sudo find /home/jit -maxdepth 1 -mindepth 1 ! -name workspace -exec chown -R 1000:1000 {} +
sudo chown 1000:1000 /home/jit/workspace/tmp /home/jit/workspace/log

exec "$@"
