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

echo "=== Locating raw image ==="
RAW_IMAGE=$(find "$REPO_ROOT" /tmp -maxdepth 3 -name 'ultramarine-gnome-44-pipa.raw' -type f 2>/dev/null | head -n1)
if [ -z "$RAW_IMAGE" ]; then
    echo "ERROR: Could not find ultramarine-gnome-44-pipa.raw"
    echo "Files in $REPO_ROOT:"
    ls -la "$REPO_ROOT"/*.raw 2>/dev/null || echo "  (none)"
    echo "Files in katsu-work:"
    ls -la "$REPO_ROOT"/katsu-work/*.raw 2>/dev/null || echo "  (none)"
    find "$REPO_ROOT" -name '*.raw' -type f 2>/dev/null || true
    exit 1
fi
echo "Found: $RAW_IMAGE"

echo "=== Phase 2: Post-process image ==="
"$REPO_ROOT/scripts/post-process-image.sh" "$RAW_IMAGE"

echo ""
echo "=== Summarize output ==="
ls -lh "$REPO_ROOT/output/" 2>/dev/null || true

echo ""
echo "=============================================="
echo " Build complete!"
echo "=============================================="
