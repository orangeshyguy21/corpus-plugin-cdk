#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(awk -F'"' '/^version = / {print $2; exit}' "$ROOT/plugin.toml")"
OUT="$ROOT/.artifacts"
mkdir -p "$OUT"
ARCHIVE="$OUT/corpus-plugin-cdk-$VERSION.tar.gz"

git -C "$ROOT" archive --format=tar.gz --prefix="corpus-plugin-cdk-$VERSION/" -o "$ARCHIVE" HEAD
if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$ARCHIVE" >"$ARCHIVE.sha256"
else
    sha256sum "$ARCHIVE" >"$ARCHIVE.sha256"
fi
echo "$ARCHIVE"
