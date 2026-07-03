#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="$REPO_ROOT/repo"

echo "=== Setting up Ultramarine Pipa build environment ==="

if ! command -v rpmbuild &>/dev/null; then
    echo "Installing RPM build tools..."
    if command -v dnf &>/dev/null; then
        sudo dnf install -y rpm-build rpmdevtools mock createrepo_c
    elif command -v pacman &>/dev/null; then
        echo "On Arch Linux: install rpm-tools and mock from AUR, or use a Fedora container"
        echo "Recommended: podman run --rm -it -v $REPO_ROOT:/work:Z fedora:44 bash"
        exit 1
    fi
fi

echo "=== Creating RPM build tree ==="
rpmdev-setuptree 2>/dev/null || true

echo "=== Creating local repo directory ==="
mkdir -p "$REPO_DIR"
createrepo_c "$REPO_DIR" 2>/dev/null || true

echo "=== Done ==="
echo "Build RPMs with: ./scripts/build-rpm.sh <specfile>"
echo "Then refresh repo: ./scripts/refresh-repo.sh"
