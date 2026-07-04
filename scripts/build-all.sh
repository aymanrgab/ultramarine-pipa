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
RAW_IMAGE="$REPO_ROOT/katsu-work/image/katsu.img"
if [ ! -f "$RAW_IMAGE" ]; then
    echo "ERROR: Katsu image not found at $RAW_IMAGE"
    find "$REPO_ROOT/katsu-work" -type f 2>/dev/null || true
    exit 1
fi
echo "Image: $RAW_IMAGE ($(du -h "$RAW_IMAGE" | cut -f1))"

sudo "$REPO_ROOT/scripts/post-process-image.sh" "$RAW_IMAGE"

echo ""
echo "=============================================="
echo " Build complete!"
echo " Flash with: output/ultramarine-pipa-gnome-*/flash.sh"
echo "=============================================="
