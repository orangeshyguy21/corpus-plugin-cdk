# corpus-plugin-cdk

`cdk-regtest` is the reference protocol-v1 environment plugin for Corpus. It
connects a pinned CDK checkout and Cashu NUT specification to a real regtest
Lightning mint, a session-scoped egress-denied attacker sandbox, bounded
funding helpers, and host-side invariant oracles.

The repository name is `corpus-plugin-cdk`; its stable Corpus manifest id is
`cdk-regtest`.

## Operator flow

Corpus owns installation, source fetching, runtime state, and lifecycle:

```bash
corpus plugin install /path/to/corpus-plugin-cdk
corpus plugin setup cdk-regtest
corpus plugin doctor cdk-regtest
corpus plugin status cdk-regtest
```

Do not run `setup.sh` from an installed bundle. Corpus calls the executable
with explicit read-only plugin, writable state, source-cache, project, mission,
and session paths. Mission launch opens a durable environment session; Stop
closes it. `tmux` belongs to the Corpus run frontend and is not required by
this plugin.

Docker Desktop or OrbStack, Nix, `jq`, `curl`, and Bash are required. Setup
builds the shared attacker image and CDK client into Corpus-owned runtime
state. When the configured mint ports are unused it launches CDK's pinned,
non-interactive `start-regtest-mints` flake app and records the process and
working tree beneath plugin state. If compatible mints are already listening,
setup adopts them without taking teardown ownership. Session-specific gateway,
network, sandbox, evidence, and wallet resources are created and removed by
the plugin.

`corpus plugin stop cdk-regtest` refuses while sessions are live, then stops
only a backbone launched by this plugin. An adopted backbone is never killed.

## Trust boundary

- The attacker receives only the declared source mounts, tools, evidence
  directory, and target gateway.
- Its testing network has no general internet egress.
- Docker access, Lightning credentials, faucet implementation, environment
  locks, and oracle implementations remain host-side.
- Every mutable artifact lives beneath the `state_dir` supplied by Corpus;
  the installed plugin bundle remains read-only.

## Development

```bash
scripts/conformance.sh /path/to/corpus
scripts/smoke.sh /path/to/corpus
scripts/package.sh
```

Protocol additions land in Corpus with a conformance fixture first. This
plugin then adopts the released contract; Corpus raises its required plugin
version only after a compatible plugin release exists.

The adapter originated in the Corpus monorepo. Its directory history was
preserved when this repository was extracted. CDK and Cashu are upstream
projects and retain their respective licenses; no upstream source is vendored
here.
