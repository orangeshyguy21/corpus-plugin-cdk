# Changelog

## 0.3.7 — 2026-08-18

- Let lifecycle setup start CDK's pinned non-interactive regtest when targets
  are absent, while safely adopting but never stopping an existing backbone.
- Record a full environment SHA-256 and pass the owned/adopted work directory
  explicitly to faucet and oracle operations.
- Reload resolved source mounts from the durable session record on every call,
  so an incomplete caller cannot weaken or erase the opened session context.
- Make the CI Docker smoke job build the attacker image on every change.

## 0.3.2 — 2026-08-18

- Adopt `corpus.environment/1` and a self-describing v1 manifest.
- Move setup, source custody, tools, evidence, and session state out of the
  immutable bundle.
- Scope Docker networks, gateway, sandbox, and cleanup by environment session.
- Move attacker-wallet quote/pay/claim behavior behind `wallet.fund`.
