#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORPUS_ROOT="${1:-$ROOT/../corpus}"
export CORPUS_PLUGINS_DIR="$(dirname "$ROOT")"

cargo run -q --manifest-path "$CORPUS_ROOT/Cargo.toml" -p corpus-cli -- plugin doctor cdk-regtest
echo "smoke: doctor pass"
