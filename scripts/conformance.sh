#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORPUS_ROOT="${1:-$ROOT/../corpus}"
VERSION="$(awk -F'"' '/^version = / {print $2; exit}' "$ROOT/plugin.toml")"

bash -n "$ROOT/plugin" "$ROOT/arena.sh" "$ROOT/faucet.sh" "$ROOT/tools/build-tools.sh"

hello="$(printf '%s\n' '{"id":1,"method":"hello","params":{}}' | "$ROOT/plugin")"
jq -e '.id==1 and .ok==true and .result.protocol=="corpus.environment/1"' <<<"$hello" >/dev/null
jq -e '.result.capabilities | sort == ["faucet.bolt11","lifecycle.setup","oracle.run","sandbox.exec","sessions","wallet.fund"]' <<<"$hello" >/dev/null

bad="$(printf '%s\n' '{"id":2,"method":"session_probe","params":{"session_id":"invalid"}}' | "$ROOT/plugin")"
jq -e '.id==2 and .ok==false and .error.code=="session_not_ready" and (.error.retryable|type)=="boolean"' <<<"$bad" >/dev/null

if [ -d "$CORPUS_ROOT/.git" ]; then
    CORPUS_PLUGINS_DIR="$(dirname "$ROOT")" \
        cargo run -q --manifest-path "$CORPUS_ROOT/Cargo.toml" -p corpus-cli -- plugin list \
        | grep -q "cdk-regtest.*$VERSION.*override"
    cargo test --manifest-path "$CORPUS_ROOT/Cargo.toml" -p corpus-core --test protocol
fi

echo "conformance: pass"
