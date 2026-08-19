#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(awk -F'"' '/^version = / {print $2; exit}' "$ROOT/plugin.toml")"
OUT="$ROOT/.artifacts"
mkdir -p "$OUT"
ARCHIVE_NAME="corpus-plugin-cdk-$VERSION.tar.gz"
ARCHIVE="$OUT/$ARCHIVE_NAME"

git -C "$ROOT" archive --format=tar.gz --prefix="corpus-plugin-cdk-$VERSION/" -o "$ARCHIVE" HEAD
if command -v shasum >/dev/null 2>&1; then
    (cd "$OUT" && shasum -a 256 "$ARCHIVE_NAME" >"$ARCHIVE_NAME.sha256")
else
    (cd "$OUT" && sha256sum "$ARCHIVE_NAME" >"$ARCHIVE_NAME.sha256")
fi
echo "$ARCHIVE"
