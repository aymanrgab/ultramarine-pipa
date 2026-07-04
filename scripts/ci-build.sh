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
echo "Working directory: $(pwd)"
echo "Katsu version: $(katsu --version 2>&1 || echo unknown)"
echo "Running: katsu -o disk-image $REPO_ROOT/katsu/modules/ports/pipa/pipa-gnome.yaml"
katsu -o disk-image "$REPO_ROOT/katsu/modules/ports/pipa/pipa-gnome.yaml"
KATSU_RC=$?
echo "Katsu exit code: $KATSU_RC"

echo ""
echo "=== Locating raw image ==="
echo "Searching for image files..."

echo "--- All .raw and .img files on system ---"
find / -maxdepth 6 \( -name '*.raw' -o -name '*.img' \) -type f 2>/dev/null || true

echo "--- Contents of /build (top-level) ---"
ls -la /build/ 2>/dev/null || true

echo "--- Contents of /build/katsu-work ---"
ls -laR /build/katsu-work/ 2>/dev/null | head -50 || echo "  (no katsu-work directory)"

echo "--- Files larger than 100M anywhere under /build ---"
find /build -type f -size +100M 2>/dev/null || echo "  (none)"

echo "--- out_file from YAML ---"
grep -i 'out_file' "$REPO_ROOT/katsu/modules/ports/pipa/pipa-gnome.yaml" 2>/dev/null || true

RAW_IMAGE=$(find / -maxdepth 6 -name 'ultramarine-gnome-44-pipa.raw' -type f 2>/dev/null | head -n1)
if [ -z "$RAW_IMAGE" ]; then
    RAW_IMAGE=$(find / -maxdepth 6 -name '*.raw' -type f -size +500M 2>/dev/null | head -n1)
fi
if [ -z "$RAW_IMAGE" ]; then
    echo ""
    echo "ERROR: No raw disk image found anywhere."
    echo "Katsu may not have created a disk image."
    echo "Check if katsu-work/chroot was populated:"
    ls /build/katsu-work/chroot/ 2>/dev/null | head -20 || echo "  (chroot empty or missing)"
    exit 1
fi
echo "Found image: $RAW_IMAGE ($(du -h "$RAW_IMAGE" | cut -f1))"

echo ""
echo "=== Phase 2: Post-process image ==="
"$REPO_ROOT/scripts/post-process-image.sh" "$RAW_IMAGE"

echo ""
echo "=== Summarize output ==="
ls -lh "$REPO_ROOT/output/" 2>/dev/null || true

echo ""
echo "=============================================="
echo " Build complete!"
echo "=============================================="
