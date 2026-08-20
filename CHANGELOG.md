# Changelog

## 0.4.5 — 2026-08-20

- Add pinned Coincurve 21.0.0 to the attacker sandbox for secp256k1 and BIP340
  Schnorr PoCs.
- Verify Schnorr signing and verification in the sandbox smoke test.

## 0.4.4 — 2026-08-19

- Export the launcher work directory as `CDK_ITESTS_DIR`, matching the pinned
  integration harness's internal runtime contract as well as its CLI argument.

## 0.4.3 — 2026-08-19

- Apply a recorded compatibility patch to the pinned regtest launcher that
  raises Bitcoin Core's JSON-RPC timeout during initial block generation.
  This avoids false startup failures while preserving the pinned CDK source
  and dependency lock.

## 0.4.2 — 2026-08-19

- Launch `start_regtest_mints` inside CDK's pinned `regtest` Nix environment
  so `bitcoind`, Core Lightning, LND, and the other runtime daemons are on PATH.

## 0.4.1 — 2026-08-19

- Start the pinned CDK regtest package through its actual
  `start_regtest_mints` binary instead of relying on Nix's incorrect inferred
  main-program name.

## 0.4.0 — 2026-08-19

- Add Python 3 with Requests for rapid protocol scripting.
- Add a disposable writable `/work` tmpfs while keeping the root filesystem,
  source corpus, and tools read-only.
- Advertise the available scripting runtimes and PoC workspace to agents.

## 0.3.8 — 2026-08-18

- Let lifecycle setup start CDK's pinned non-interactive regtest when targets
  are absent, while safely adopting but never stopping an existing backbone.
- Record a full environment SHA-256 and pass the owned/adopted work directory
  explicitly to faucet and oracle operations.
- Reload resolved source mounts from the durable session record on every call,
  so an incomplete caller cannot weaken or erase the opened session context.
- Make the CI Docker smoke job build the attacker image on every change.
- Emit portable checksum files containing the release archive basename rather
  than a build-machine absolute path.

## 0.3.2 — 2026-08-18

- Adopt `corpus.environment/1` and a self-describing v1 manifest.
- Move setup, source custody, tools, evidence, and session state out of the
  immutable bundle.
- Scope Docker networks, gateway, sandbox, and cleanup by environment session.
- Move attacker-wallet quote/pay/claim behavior behind `wallet.fund`.
