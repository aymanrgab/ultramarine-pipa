#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=============================================="
echo " Ultramarine OS for Xiaomi Pad 6 (pipa)"
echo " Full build pipeline"
echo " Packages from: thespider2.github.io/pipa-pkgs"
echo "=============================================="
echo

echo "=== Phase 1: Build Katsu image ==="
katsu -o disk-image "$REPO_ROOT/katsu/modules/ports/pipa/pipa-gnome.yaml"

echo "=== Phase 2: Post-process image ==="
sudo "$REPO_ROOT/scripts/post-process-image.sh" "$REPO_ROOT/ultramarine-gnome-44-pipa.raw"

echo ""
echo "=============================================="
echo " Build complete!"
echo " Flash with: output/ultramarine-pipa-gnome-*/flash.sh"
echo "=============================================="
