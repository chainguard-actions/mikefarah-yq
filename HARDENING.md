<!-- markdownlint-disable -->

# Hardening Report: mikefarah--yq/v4.53.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **mikefarah--yq/v4.53.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The Docker action in action.yml references the image 'docker://mikefarah/yq:4-githubaction' using a mutable tag ('4-githubaction') instead of an immutable SHA digest. This means the image can be silently replaced with a different (potentially malicious) version without any change to the action definition, creating a supply-chain attack risk. It should be pinned to a specific SHA digest, e.g. 'docker://mikefarah/yq@sha256:<64-hex-char-digest>'.

Locations:

- `action.yml:14`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses

**Notes:**

Replaced mutable Docker image tag 'docker://mikefarah/yq:4-githubaction' with immutable SHA digest 'docker://mikefarah/yq@sha256:e1b8c865f299ea6b02910a7ddf147d5d431244d4cc116f89c2148c9f53822906 # 4-githubaction' in action.yml line 14. The original tag is preserved as a comment for readability.

