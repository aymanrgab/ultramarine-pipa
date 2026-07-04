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

echo "=== Locating raw image ==="
RAW_IMAGE=$(find "$REPO_ROOT" /tmp -maxdepth 3 -name 'ultramarine-gnome-44-pipa.raw' -type f 2>/dev/null | head -n1)
if [ -z "$RAW_IMAGE" ]; then
    echo "ERROR: Could not find ultramarine-gnome-44-pipa.raw"
    find "$REPO_ROOT" -name '*.raw' -type f 2>/dev/null || true
    exit 1
fi
echo "Found: $RAW_IMAGE"

echo "=== Phase 2: Post-process image ==="
sudo "$REPO_ROOT/scripts/post-process-image.sh" "$RAW_IMAGE"

echo ""
echo "=============================================="
echo " Build complete!"
echo " Flash with: output/ultramarine-pipa-gnome-*/flash.sh"
echo "=============================================="
