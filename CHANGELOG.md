# Changelog

## 0.3.2 — unreleased

- Adopt `corpus.environment/1` and a self-describing v1 manifest.
- Move setup, source custody, tools, evidence, and session state out of the
  immutable bundle.
- Scope Docker networks, gateway, sandbox, and cleanup by environment session.
- Move attacker-wallet quote/pay/claim behavior behind `wallet.fund`.
