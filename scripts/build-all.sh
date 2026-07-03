#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PIPA_PKGS="${PIPA_PKGS:-/home/ayman/pipa-pkgs}"
export PIPA_PKGS

echo "=============================================="
echo " Ultramarine OS for Xiaomi Pad 6 (pipa)"
echo " Full build pipeline"
echo "=============================================="
echo

echo "=== Phase 1: Link source files ==="
"$REPO_ROOT/scripts/link-sources.sh"

echo "=== Phase 2: Build all RPMs ==="
for spec in "$REPO_ROOT/specs/"*.spec; do
    name=$(basename "$spec" .spec)
    echo "--- Building: $name ---"
    "$REPO_ROOT/scripts/build-rpm.sh" "$spec" || {
        echo "WARNING: Failed to build $name, continuing..."
    }
done

echo "=== Phase 3: Refresh local repo ==="
"$REPO_ROOT/scripts/refresh-repo.sh"

echo "=== Phase 4: Build Katsu image ==="
katsu -o disk-image "$REPO_ROOT/katsu/modules/ports/pipa/pipa-gnome.yaml"

echo "=== Phase 5: Post-process image ==="
sudo "$REPO_ROOT/scripts/post-process-image.sh" "$REPO_ROOT/ultramarine-gnome-44-pipa.raw"

echo ""
echo "=============================================="
echo " Build complete!"
echo " Flash with: output/ultramarine-pipa-gnome-*/flash.sh"
echo "=============================================="
