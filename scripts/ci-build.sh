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
"$REPO_ROOT/scripts/post-process-image.sh" "$REPO_ROOT/ultramarine-gnome-44-pipa.raw"

echo ""
echo "=== Summarize output ==="
ls -lh "$REPO_ROOT/output/" 2>/dev/null || true

echo ""
echo "=============================================="
echo " Build complete!"
echo "=============================================="
