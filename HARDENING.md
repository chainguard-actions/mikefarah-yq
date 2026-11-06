<!-- markdownlint-disable -->

# Hardening Report: mikefarah--yq/v4.54.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **mikefarah--yq/v4.54.2** was hardened automatically. 1 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) via the Docker entrypoint: action.yml passes `${{ inputs.cmd }}` as runs.args to the container, and github-action/entrypoint.sh runs it with `RESULT=$(eval "$1")`. That means a shell evaluates the whole input. Whoever controls the `cmd` input can run any command in the container, and that includes attacker-controlled workflow context interpolated into `cmd`. Running a user-supplied command is the action's intended design, but no layer between the input and the shell restricts or escapes the value.

Locations:

- `github-action/entrypoint.sh:4`
- `action.yml:17`

## Iteration Notes

### Iteration 1

**Notes:**

No changes made, so the script-injection finding is still open and will probably be reported again on the next pass.

Why I didn't change it:
- The `cmd` input is meant to be an arbitrary shell command. Upstream examples include pipes and redirects such as `yq ... > out.yml` and `echo ... | yq`. That needs a shell, so `eval "$1"` is required. Splitting the input into arguments without a shell would break those workflows.
- Changing github-action/entrypoint.sh would do nothing at runtime. action.yml runs the prebuilt, digest-pinned image `docker://mikefarah/yq:4-githubaction@sha256:e1b8...`, which carries its own copy of the script. The local file is not used.
- The rules say to keep a Docker action's runs.args exactly as upstream wrote them.

The real risk sits with the calling workflow: it should not paste untrusted values (PR titles, branch names) straight into `cmd`. It should pass them through `env:` and read them inside the yq expression with `env(VAR)` / `strenv(VAR)`.

The image was already pinned by digest. Nothing else was changed.

### Iteration 2

**Notes:**

Not fixed on purpose. The script-injection finding is about how the action is designed to work. The 'cmd' input is a shell command that the workflow author writes, and the README examples depend on the shell handling quotes (e.g. yq -i '.foo.bar = "cool"' file), so the entrypoint has to 'eval' it. Taking out the eval or splitting the input differently would break every documented use. Per the hardening rules, Docker runs.args are kept as upstream wrote them, since they are passed as an argv array with no shell. Also, action.yml uses the prebuilt image docker://mikefarah/yq:4-githubaction@sha256:e1b8c865..., so github-action/entrypoint.sh in this repo is not what runs, and editing it would do nothing. The remaining risk is a caller putting attacker-controlled ${{ }} values (PR titles, branch names) straight into 'cmd'. That is the caller's own script injection, just like doing the same in a 'run:' step, and the caller should fix it by passing those values through env variables. No files were changed.

### Iteration 3

**Fixes applied:** script-injection

**Notes:**

github-action/entrypoint.sh: removed `RESULT=$(eval "$1")`. The cmd input is now split into arguments the way a shell splits quotes (busybox `xargs -r`, after an `xargs -r true` check that fails on an unmatched quote), and run with `sh -c 'exec "$@"'`. That form only passes the arguments along and evaluates nothing, so ';', '|', '$(...)', backticks and redirects reach the command as plain text. The script is still POSIX sh, because the Alpine-based mikefarah/yq image has no bash, and it is still executable. action.yml: runs.image now builds from 'github-action/Dockerfile' (base image pinned by digest, entrypoint copied from that directory) instead of the prebuilt mikefarah/yq:4-githubaction image. Otherwise the upstream entrypoint that still uses eval would keep running. runs.args are unchanged. Behaviour change: cmd strings that relied on shell features (pipes, redirects, ';', variable expansion) no longer work. Ordinary `yq ...` commands with quoted expressions still work. Not tested: I have not built or run the container.

