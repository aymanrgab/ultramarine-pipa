#!/bin/bash
set -euo pipefail

REPO_ROOT="/build"
BUILD_GIT_REV="${BUILD_GIT_REV:-unknown}"
KATSU_DIR="$REPO_ROOT/katsu/modules/ports/pipa"
KATSU_IMAGE="$REPO_ROOT/katsu-work/image/katsu.img"

VARIANTS="${BUILD_VARIANTS:-gnome plasma}"

echo "=============================================="
echo " Ultramarine OS for Xiaomi Pad 6 (pipa)"
echo " CI Build Pipeline"
echo " Rev: $BUILD_GIT_REV"
echo " Variants: $VARIANTS"
echo "=============================================="
echo

for variant in $VARIANTS; do
    YAML="$KATSU_DIR/pipa-${variant}.yaml"
    if [ ! -f "$YAML" ]; then
        echo "SKIP: $YAML not found"
        continue
    fi

    echo ""
    echo "====== Building: $variant ======"

    echo "=== Phase 1: Build Katsu image ($variant) ==="
    rm -rf "$REPO_ROOT/katsu-work"
    katsu -o disk-image "$YAML"

    if [ ! -f "$KATSU_IMAGE" ]; then
        echo "ERROR: Katsu image not found at $KATSU_IMAGE"
        find "$REPO_ROOT/katsu-work" -type f 2>/dev/null || true
        exit 1
    fi
    echo "Image: $KATSU_IMAGE ($(du -h "$KATSU_IMAGE" | cut -f1))"

    echo "=== Phase 2: Post-process ($variant) ==="
    VARIANT_NAME="$variant" "$REPO_ROOT/scripts/post-process-image.sh" "$KATSU_IMAGE"
done

echo ""
echo "=== Summarize output ==="
ls -lhR "$REPO_ROOT/output/" 2>/dev/null || true

echo ""
echo "=============================================="
echo " Build complete!"
echo "=============================================="
