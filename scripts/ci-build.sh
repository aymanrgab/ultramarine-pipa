#!/bin/bash
set -euo pipefail

REPO_ROOT="/build"
PIPA_PKGS_REPO="${PIPA_PKGS_REPO:-https://github.com/aymanrgab/pipa-pkgs.git}"
PIPA_PKGS_BRANCH="${PIPA_PKGS_BRANCH:-main}"
BUILD_GIT_REV="${BUILD_GIT_REV:-unknown}"
DATE=$(date +%Y%m%d)

echo "=============================================="
echo " Ultramarine OS for Xiaomi Pad 6 (pipa)"
echo " CI Build Pipeline"
echo " Rev: $BUILD_GIT_REV"
echo "=============================================="
echo

echo "=== Phase 0: Clone pipa-pkgs ==="
if [ ! -d "/build/pipa-pkgs" ]; then
    git clone --depth=1 -b "$PIPA_PKGS_BRANCH" "$PIPA_PKGS_REPO" /build/pipa-pkgs
fi
export PIPA_PKGS="/build/pipa-pkgs"

echo "=== Phase 1: Link source files ==="
"$REPO_ROOT/scripts/link-sources.sh"

echo "=== Phase 2: Build all RPMs ==="
for spec in "$REPO_ROOT/specs/"*.spec; do
    name=$(basename "$spec" .spec)
    echo ""
    echo "=== Building: $name ==="

    mkdir -p ~/rpmbuild/SOURCES
    cp "$REPO_ROOT/sources/$name"/* ~/rpmbuild/SOURCES/ 2>/dev/null || true

    rpmbuild -ba "$spec" \
        --define "_topdir $HOME/rpmbuild" \
        --define "dist .um44" \
        --target "$(uname -m)" \
        2>&1 || {
        echo "WARNING: Failed to build $name, continuing..."
        continue
    }

    find ~/rpmbuild/RPMS/ -name "*.rpm" -newer "$spec" -exec cp -v {} "$REPO_ROOT/repo/" \;
    find ~/rpmbuild/SRPMS/ -name "*.rpm" -newer "$spec" -exec cp -v {} "$REPO_ROOT/repo/" \;
done

echo "=== Phase 3: Refresh local repo ==="
mkdir -p "$REPO_ROOT/repo"
createrepo_c "$REPO_ROOT/repo"

echo "=== Built RPMs ==="
ls -lh "$REPO_ROOT/repo/"*.rpm 2>/dev/null || echo "(no RPMs)"

echo "=== Phase 4: Build Katsu image ==="
katsu -o disk-image "$REPO_ROOT/katsu/modules/ports/pipa/pipa-gnome.yaml"

echo "=== Phase 5: Post-process image ==="
"$REPO_ROOT/scripts/post-process-image.sh" "$REPO_ROOT/ultramarine-gnome-44-pipa.raw"

echo ""
echo "=== Summarize output ==="
ls -lh "$REPO_ROOT/output/" 2>/dev/null || true

echo ""
echo "=============================================="
echo " Build complete!"
echo "=============================================="
