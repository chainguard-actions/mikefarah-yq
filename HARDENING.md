<!-- markdownlint-disable -->

# Hardening Report: mikefarah--yq/v4.53.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **mikefarah--yq/v4.53.2** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple unpinned action/image references found:
- action.yml: `image: 'docker://mikefarah/yq:4-githubaction'` uses a mutable tag instead of a SHA digest.
- release.yml: `uses: sigstore/cosign-installer@v3` uses a version tag instead of a commit SHA; `uses: docker://pandoc/core:2.14.2` uses a mutable image tag instead of a SHA digest.
- scorecard.yml: `uses: github/codeql-action/upload-sarif@v3` uses a version tag instead of a commit SHA.
- test-yq.yml: `uses: mikefarah/yq@master` (appears twice) uses a branch name instead of a commit SHA.

Locations:

- `action.yml:15`
- `.github/workflows/release.yml:32`
- `.github/workflows/release.yml:46`
- `.github/workflows/scorecard.yml:76`
- `.github/workflows/test-yq.yml:19`
- `.github/workflows/test-yq.yml:26`

### script-injection (severity: high)

Direct expression interpolation inside run: blocks:
- docker-release.yml line 36: `run: echo ${{ steps.buildx.outputs.platforms }} && docker version` — `steps.*.outputs.*` value interpolated directly into shell command (sub-rule a).
- test-yq.yml line 23: `run: echo "### It was [${{ steps.get_value.outputs.result }}]" >> $GITHUB_STEP_SUMMARY` — `steps.*.outputs.*` value interpolated directly into shell command (sub-rule a).

Locations:

- `.github/workflows/docker-release.yml:36`
- `.github/workflows/test-yq.yml:23`

### broad-permissions (severity: medium)

scorecard.yml has a top-level `permissions: read-all` which grants overly broad read access across all scopes. This should be replaced with specific minimal permissions scoped to what the workflow actually needs.

Locations:

- `.github/workflows/scorecard.yml:18`

### unsafe-shell (severity: high)

go.yml pipes remote content directly to a shell interpreter: `curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh`. The script should be downloaded to a file first, verified, and then executed separately.

Locations:

- `.github/workflows/go.yml:27`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, broad-permissions, unsafe-shell

**Notes:**

Fixed all four findings:
1. unpinned-uses: Pinned mikefarah/yq:4-githubaction image in action.yml to SHA digest; pinned pandoc/core:2.14.2 and sigstore/cosign-installer@v3 in release.yml; pinned github/codeql-action/upload-sarif@v3 in scorecard.yml; pinned both mikefarah/yq@master references in test-yq.yml to commit SHA.
2. script-injection: Moved ${{ steps.buildx.outputs.platforms }} to env block in docker-release.yml; moved ${{ steps.get_value.outputs.result }} to env block in test-yq.yml.
3. broad-permissions: Replaced 'permissions: read-all' with 'permissions:\n  contents: read' in scorecard.yml (job-level permissions already cover security-events: write and id-token: write).
4. unsafe-shell: Replaced 'curl ... | sh' with download-then-execute pattern in go.yml.

