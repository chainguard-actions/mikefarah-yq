<!-- markdownlint-disable -->

# Hardening Report: mikefarah--yq/v4.53.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **mikefarah--yq/v4.53.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The action.yml uses a Docker image with a mutable tag instead of a SHA digest. The image reference `docker://mikefarah/yq:4-githubaction` uses the tag `4-githubaction`, which can be silently replaced with a different (potentially malicious) image. It should be pinned to a specific SHA digest, e.g. `docker://mikefarah/yq@sha256:<64-hex-char-digest>`.

Locations:

- `action.yml:14`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses

**Notes:**

Replaced the mutable Docker image tag `docker://mikefarah/yq:4-githubaction` with the immutable SHA digest `docker://mikefarah/yq@sha256:e1b8c865f299ea6b02910a7ddf147d5d431244d4cc116f89c2148c9f53822906` in action.yml line 14. The original tag `4-githubaction` is preserved as a comment outside the YAML string for readability.

