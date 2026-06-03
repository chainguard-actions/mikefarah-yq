# Hardening Report: mikefarah--yq/v4.53.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `ff50f15e4b79bfbf764dafdfd2579175a6ea9771`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **mikefarah--yq/v4.53.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The action.yml uses a Docker image with a mutable tag instead of an immutable SHA digest. The image 'docker://mikefarah/yq:4-githubaction' uses the tag '4-githubaction', which can be changed at any time by the image owner, enabling supply-chain attacks. It should be pinned to a specific SHA256 digest, e.g. 'docker://mikefarah/yq@sha256:<64-hex-char-digest>'.

Locations:

- `action.yml:13`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses

**Notes:**

Pinned the Docker image 'mikefarah/yq:4-githubaction' to its immutable SHA256 digest 'sha256:93b83184c74b89abf728fbb27db3dc0a9ca06b826b3b2ee41357a9b992eaef0f' in action.yml line 13. The original tag is preserved as a comment for readability.

