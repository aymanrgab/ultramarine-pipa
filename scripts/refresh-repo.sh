#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="$REPO_ROOT/repo"

echo "=== Refreshing local RPM repo ==="
createrepo_c --update "$REPO_DIR"
echo "=== Repo updated: $(find "$REPO_DIR" -name '*.rpm' | wc -l) packages ==="
