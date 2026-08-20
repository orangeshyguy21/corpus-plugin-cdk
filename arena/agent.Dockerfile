# cdk-regtest attacker image (absorbed from the cdk PoC harness, 2026-08-10).
#
# Toolchain policy: agents get Python for fast protocol/request scripting and
# precompiled tools mounted read-only at /opt/tools. Native build toolchains do
# not belong in the attacker image; CDK tools are compiled during setup.
#
# Hardening is applied at runtime (see arena.sh): dropped capabilities,
# read-only root fs, no-new-privileges, resource caps. This Dockerfile only
# guarantees a non-root default user and a sane PID 1.
FROM debian:stable-slim@sha256:1710bde34461551a19a47c787885ec9ad7058d9a5bead2affb8d088fa2f8502b

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        git \
        jq \
        python3 \
        python3-requests \
        sqlite3 \
        socat \
        tini \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash attacker

USER attacker
WORKDIR /work

# tini as PID 1: reaps zombies from fork-heavy attack scripts.
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash"]
