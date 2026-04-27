#!/usr/bin/env bash
set -euo pipefail

# Fix ownership under /home/global (dotfiles, caches, tmpfs mounts, etc.).
# Skip the workspace bind mount to avoid traversing the entire project tree.
sudo chown 1000:1000 /home/global
sudo find /home/global -maxdepth 1 -mindepth 1 ! -name workspace -exec chown -R 1000:1000 {} +
sudo chown 1000:1000 /home/global/workspace/tmp /home/global/workspace/log

exec "$@"
