<!-- markdownlint-disable -->

# Hardening Report: mikefarah--yq/v4.52.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **mikefarah--yq/v4.52.5** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple workflow files and action.yml reference actions and Docker images by mutable version tags instead of immutable full SHA digests, making them vulnerable to supply-chain attacks.

- action.yml: `image: 'docker://mikefarah/yq:4-githubaction'` (mutable tag, not a SHA digest)
- codeql.yml: `actions/checkout@v6`, `github/codeql-action/init@v4`, `github/codeql-action/autobuild@v4`, `github/codeql-action/analyze@v4`
- docker-release.yml: `actions/checkout@v6`, `docker/setup-qemu-action@v4`, `docker/setup-buildx-action@v4`, `docker/login-action@v4` (×2)
- go.yml: `actions/setup-go@v6`, `actions/checkout@v6`
- release.yml: `actions/checkout@v6`, `actions/setup-go@v6`, `docker://pandoc/core:2.14.2` (tag), `softprops/action-gh-release@v1`
- snap-release.yml: `actions/checkout@v6`, `snapcore/action-build@v1`, `snapcore/action-publish@v1`
- test-yq.yml: `actions/checkout@v6`, `mikefarah/yq@master` (×2)

Locations:

- `action.yml:14`
- `.github/workflows/codeql.yml:34`
- `.github/workflows/codeql.yml:39`
- `.github/workflows/codeql.yml:46`
- `.github/workflows/codeql.yml:55`
- `.github/workflows/docker-release.yml:14`
- `.github/workflows/docker-release.yml:17`
- `.github/workflows/docker-release.yml:23`
- `.github/workflows/docker-release.yml:30`
- `.github/workflows/docker-release.yml:36`
- `.github/workflows/go.yml:13`
- `.github/workflows/go.yml:18`
- `.github/workflows/release.yml:11`
- `.github/workflows/release.yml:12`
- `.github/workflows/release.yml:26`
- `.github/workflows/release.yml:43`
- `.github/workflows/snap-release.yml:13`
- `.github/workflows/snap-release.yml:14`
- `.github/workflows/snap-release.yml:18`
- `.github/workflows/test-yq.yml:14`
- `.github/workflows/test-yq.yml:17`
- `.github/workflows/test-yq.yml:23`

### permissions (severity: medium)

missing-permissions: The following workflow files have no top-level `permissions:` key and no job-level `permissions:` keys on any of their jobs, meaning the GITHUB_TOKEN is granted default (potentially write) permissions:
- docker-release.yml
- release.yml
- snap-release.yml

Locations:

- `.github/workflows/docker-release.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/snap-release.yml:1`

### script-injection (severity: high)

Rule (a): GitHub Actions expressions are interpolated directly inside `run:` shell command strings, allowing expression values to be interpreted as shell code before the shell ever sees them.

1. docker-release.yml — `run: echo ${{ steps.buildx.outputs.platforms }} && docker version`: the `steps.buildx.outputs.platforms` expression is injected directly into the shell command.

2. test-yq.yml — `run: echo "### It was [${{ steps.get_value.outputs.result }}]" >> $GITHUB_STEP_SUMMARY`: the `steps.get_value.outputs.result` expression (which is the output of a yq command run against user-supplied input) is injected directly into the shell command.

Locations:

- `.github/workflows/docker-release.yml:27`
- `.github/workflows/test-yq.yml:20`

### unsafe-shell (severity: high)

go.yml pipes a remotely-fetched shell script directly to `sh` without first downloading and verifying it: `curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh`. If the remote URL is compromised or the content is tampered with in transit, arbitrary code will execute on the runner.

Locations:

- `.github/workflows/go.yml:24`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, permissions, script-injection, unsafe-shell

**Notes:**

Fixed all four findings across 7 files:

1. **unpinned-uses**: Pinned all action references to full commit SHAs and container images to sha256 digests. The docker:// scheme in action.yml was preserved. All 22 locations addressed.

2. **permissions**: Added top-level `permissions:` blocks to docker-release.yml (contents: read, packages: write), release.yml (contents: write for creating releases), and snap-release.yml (contents: read).

3. **script-injection**: In docker-release.yml, moved `${{ steps.buildx.outputs.platforms }}` to an env var `BUILDX_PLATFORMS`. In test-yq.yml, moved `${{ steps.get_value.outputs.result }}` to an env var `YQ_RESULT`.

4. **unsafe-shell**: In go.yml, replaced `curl ... | sh` with a two-step approach: download to a temp file with `mktemp`, then execute the script file directly (no `--` needed as the original script took no positional arguments).

