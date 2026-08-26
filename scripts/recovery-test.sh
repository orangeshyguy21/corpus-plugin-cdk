#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Loading the adapter with closed stdin defines its functions without handling
# a protocol request. Every host interaction used below is replaced by a fake.
# shellcheck source=../plugin
source "$ROOT/plugin" </dev/null

fail() { echo "recovery-test: $*" >&2; exit 1; }
new_fixture() {
    TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/corpus-cdk-recovery.XXXXXX")"
    STATE_DIR="$TEST_ROOT/state"
    BACKBONE_DIR="$STATE_DIR/backbone"
    BACKBONE_RECORD="$STATE_DIR/backbone.json"
    mkdir -p "$STATE_DIR/operations"
    ACTIVE=0 START_FAIL=false MOCK_LOG="$TEST_ROOT/calls"
}
cleanup_fixture() { rm -rf -- "$TEST_ROOT"; }
active_session_count() { printf '%s' "$ACTIVE"; }
stop_backbone() { printf 'stop\n' >>"$MOCK_LOG"; rm -f "$BACKBONE_RECORD"; }
start_backbone() {
    printf 'start\n' >>"$MOCK_LOG"
    mkdir -p "$BACKBONE_DIR"
    printf 'new\n' >"$BACKBONE_DIR/generation"
    if [ "$START_FAIL" = true ]; then printf 'synthetic launcher failure'; return 1; fi
    if [ "$START_FAIL" = once ] && [ "$(grep -c '^start$' "$MOCK_LOG")" -eq 1 ]; then printf 'synthetic first failure'; return 1; fi
    atomic_json "$BACKBONE_RECORD" '{"ownership":"plugin","pid":123,"state":"ready"}'
}
targets_ready() { return 1; }

# Stale plugin state is replaced without requiring an operator to find and
# delete hidden runtime files.
new_fixture
mkdir -p "$BACKBONE_DIR"; printf 'stale\n' >"$BACKBONE_DIR/generation"
atomic_json "$BACKBONE_RECORD" '{"ownership":"plugin","pid":99,"state":"starting"}'
reset_and_start_backbone /fake/cdk || fail "stale state did not recover"
[ "$(grep -c '^start$' "$MOCK_LOG")" -eq 1 ] && [ "$(grep -c '^stop$' "$MOCK_LOG")" -eq 1 ] || fail "recovery did not stop once and start once"
[ "$(cat "$BACKBONE_DIR/generation")" = new ] || fail "fresh generation was not installed"
[ -z "$(find "$STATE_DIR" -maxdepth 1 -name 'backbone.failed.*' -print -quit)" ] || fail "successful recovery left a quarantine"
cleanup_fixture

# A first-ever partial startup gets one automatic retry from a clean directory.
new_fixture
START_FAIL=once
ensure_backbone /fake/cdk || fail "first-start failure did not retry"
[ "$(grep -c '^start$' "$MOCK_LOG")" -eq 2 ] || fail "first-start recovery did not make exactly two attempts"
[ "$(cat "$BACKBONE_DIR/generation")" = new ] || fail "retry did not retain the clean generation"
cleanup_fixture

# Recovery is transactional: a failed clean attempt restores the diagnostic
# state and its ownership record.
new_fixture
mkdir -p "$BACKBONE_DIR"; printf 'stale\n' >"$BACKBONE_DIR/generation"
atomic_json "$BACKBONE_RECORD" '{"ownership":"plugin","pid":99,"state":"starting"}'
START_FAIL=true
if reset_and_start_backbone /fake/cdk >/dev/null; then fail "failed clean start reported success"; fi
[ "$(cat "$BACKBONE_DIR/generation")" = stale ] || fail "failed recovery did not restore stale state"
[ "$(jq -r .pid "$BACKBONE_RECORD")" -eq 99 ] || fail "failed recovery did not restore its record"
cleanup_fixture

# Live sessions make automatic teardown unsafe.
new_fixture
mkdir -p "$BACKBONE_DIR"; printf 'stale\n' >"$BACKBONE_DIR/generation"
ACTIVE=1
if reset_and_start_backbone /fake/cdk >/dev/null; then fail "recovery ignored an active session"; fi
[ ! -e "$MOCK_LOG" ] || fail "active-session refusal mutated the topology"
cleanup_fixture

echo "recovery-test: pass"
