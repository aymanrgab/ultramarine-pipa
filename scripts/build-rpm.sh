#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SPEC="$1"

if [ ! -f "$SPEC" ]; then
    echo "Usage: $0 <path-to-spec-file>"
    exit 1
fi

SPEC_NAME="$(basename "$SPEC" .spec)"
echo "=== Building $SPEC_NAME ==="

cp "$REPO_ROOT/sources/$SPEC_NAME"/* ~/rpmbuild/SOURCES/ 2>/dev/null || true

rpmbuild -ba "$SPEC" \
    --define "_topdir $HOME/rpmbuild" \
    --define "dist .um44" \
    --target aarch64

echo "=== Copying RPMs to repo ==="
find ~/rpmbuild/RPMS/ -name "*.rpm" -newer "$SPEC" -exec cp -v {} "$REPO_ROOT/repo/" \;
find ~/rpmbuild/SRPMS/ -name "*.rpm" -newer "$SPEC" -exec cp -v {} "$REPO_ROOT/repo/" \;

echo "=== Done: $SPEC_NAME ==="
