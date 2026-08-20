<!-- markdownlint-disable -->

# Hardening Report: mikefarah--yq/v4.53.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **mikefarah--yq/v4.53.6** was hardened automatically. 5 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A ${{ }} expression is interpolated directly inside a run: shell command string. The line `run: echo ${{ steps.buildx.outputs.platforms }} && docker version` passes the step output through YAML template substitution before the shell sees it, enabling script injection if the value contains shell metacharacters.

Locations:

- `.github/workflows/docker-release.yml:35`

### script-injection (severity: high)

Sub-rule (a): A ${{ }} expression is interpolated directly inside a run: shell command string. The line `run: echo "### It was [${{ steps.get_value.outputs.result }}]" >> $GITHUB_STEP_SUMMARY` passes a step output (which reflects yq command output on user-controlled YAML) through YAML template substitution before the shell sees it, enabling script injection.

Locations:

- `.github/workflows/test-yq.yml:23`

### unpinned-uses (severity: high)

Two uses: references in test-yq.yml are pinned to the mutable branch ref @master instead of a full 40-character commit SHA. Failing references: `uses: mikefarah/yq@master` (lines 19 and 27). A branch ref can be silently updated to point to malicious code.

Locations:

- `.github/workflows/test-yq.yml:19`
- `.github/workflows/test-yq.yml:27`

### unsafe-shell (severity: high)

A run: block pipes remote content directly to a shell interpreter: `curl -sSfL https://raw.githubusercontent.com/golang/dep/1f7c19e5f52f49ffb9f956f64c010be14683468b/install.sh | env DEP_RELEASE_TAG=v0.5.4 sh`. Even though the URL contains a commit SHA, the script is not downloaded to a file and verified before execution — it is piped directly to sh.

Locations:

- `.github/workflows/go.yml:46`

### broad-permissions (severity: medium)

The workflow file has a top-level `permissions: read-all` which grants overly broad read access to all GitHub token scopes. This should be replaced with specific minimal permissions for each job.

Locations:

- `.github/workflows/scorecard.yml:18`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unpinned-uses, unsafe-shell, broad-permissions

**Notes:**

Fixed all 5 findings: (1) docker-release.yml line 35: moved ${{ steps.buildx.outputs.platforms }} to env block as PLATFORMS; (2) test-yq.yml line 23: moved ${{ steps.get_value.outputs.result }} to env block as RESULT; (3) test-yq.yml lines 19 and 27: pinned both mikefarah/yq@master to SHA c14f446382944492701b16c1ddb48bb9dbe683e3; (4) go.yml line 46: replaced curl pipe to sh with download-then-execute pattern using mktemp; (5) scorecard.yml line 18: replaced broad 'read-all' with specific 'contents: read' permission.

