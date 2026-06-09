# Hardening Report: mikefarah--yq/v4.53.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `ff50f15e4b79bfbf764dafdfd2579175a6ea9771`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **mikefarah--yq/v4.53.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The action.yml uses a Docker image reference with a mutable tag (`docker://mikefarah/yq:4-githubaction`) instead of an immutable SHA digest. This means the image pulled at runtime could change without notice, enabling supply-chain attacks. It should be pinned to a specific SHA digest, e.g. `docker://mikefarah/yq@sha256:<64-hex-char-digest>`.

Locations:

- `action.yml:13`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses

**Notes:**

Pinned the Docker image reference in action.yml from the mutable tag `docker://mikefarah/yq:4-githubaction` to the immutable digest `docker://mikefarah/yq@sha256:e1b8c865f299ea6b02910a7ddf147d5d431244d4cc116f89c2148c9f53822906` (with `# 4-githubaction` comment outside the YAML string for readability).

