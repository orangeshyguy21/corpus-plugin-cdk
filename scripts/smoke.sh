#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORPUS_ROOT="${1:-$ROOT/../corpus}"
export CORPUS_PLUGINS_DIR="$(dirname "$ROOT")"
IMAGE="corpus-cdk-agent:0.4.8"

cargo run -q --manifest-path "$CORPUS_ROOT/Cargo.toml" -p corpus-cli -- plugin doctor cdk-regtest

docker image inspect "$IMAGE" >/dev/null
docker run --rm \
    --user attacker \
    --read-only \
    --tmpfs /tmp:rw,nosuid,nodev,size=128m \
    --tmpfs /work:rw,nosuid,nodev,size=128m,uid=1000,gid=1000,mode=0700 \
    "$IMAGE" bash -c '
        set -e
        ! touch /root-filesystem-must-stay-read-only
        python3 -c "import requests; print(requests.__version__)" >/dev/null
        python3 -c "from coincurve import PrivateKey; m=b\"\\x02\"*32; k=PrivateKey(b\"\\x01\"*32); s=k.sign_schnorr(m); assert len(s)==64 and k.public_key_xonly.verify(s,m)"
        printf "print(42)\n" > /work/poc.py
        [ "$(python3 /work/poc.py)" = 42 ]
    '
echo "smoke: doctor pass"
