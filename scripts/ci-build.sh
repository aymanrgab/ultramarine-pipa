#!/bin/bash
set -euo pipefail

REPO_ROOT="/build"
BUILD_GIT_REV="${BUILD_GIT_REV:-unknown}"

echo "=============================================="
echo " Ultramarine OS for Xiaomi Pad 6 (pipa)"
echo " CI Build Pipeline"
echo " Rev: $BUILD_GIT_REV"
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

"$REPO_ROOT/scripts/post-process-image.sh" "$RAW_IMAGE"

echo ""
echo "=== Summarize output ==="
ls -lh "$REPO_ROOT/output/" 2>/dev/null || true

echo ""
echo "=============================================="
echo " Build complete!"
echo "=============================================="
