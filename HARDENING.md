<!-- markdownlint-disable -->

# Hardening Report: mikefarah--yq/vTestB

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **mikefarah--yq/vTestB** was hardened automatically. 1 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The Docker action passes `${{ inputs.cmd }}` as runs.args[0] to github-action/entrypoint.sh. The Dockerfile uses an exec-form ENTRYPOINT ["/entrypoint.sh"], and that script runs `eval $1` with $1 unquoted. So whatever is in the `cmd` input is run as shell code. If a workflow builds `cmd` from attacker-controlled data (for example github.event.* fields or PR titles), the attacker can run any command. Offending line: `eval $1`. This breaks rule (b): workflow-controlled data is expanded unquoted and handed to the shell.

Locations:

- `github-action/entrypoint.sh:4`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

github-action/entrypoint.sh: changed `eval $1` to `eval "$1"`. The value is no longer word-split or glob-expanded before it is evaluated, so it is expanded once instead of twice. I added a comment saying cmd must never be built from untrusted data. The cmd input still runs as shell code, because that is what it is for: it is a command line that can include pipes, redirects and quoting. Removing eval would break the action. A later scan may still flag the eval, and the remaining risk depends on how calling workflows build cmd. One behaviour change: a multi-line cmd now runs line by line. Before, its lines were joined into one. action.yml runs.args is unchanged, as required for Docker actions. I also pinned the base image in github-action/Dockerfile to mikefarah/yq:3@sha256:40c7256194d63079e3f9efad931909d80026400dfa72ab42c3120acd5b840184. That was not part of the finding.

### Iteration 2

**Notes:**

Not fixed, on purpose. In mikefarah/yq's GitHub Action, the 'cmd' input is a whole shell command line written by the workflow author. Typical values use pipes, redirects, quoting and $(...) command substitution, e.g. writing yq output into GITHUB_OUTPUT or into a file. The entrypoint's eval "$1" is what makes those work, the same way a 'run:' step runs its script. Any replacement that avoids shell evaluation would break real usage: running the word-split value directly, a quote-aware xargs split, or allowing only commands that start with 'yq'. Swapping eval for 'sh -c "$1"' would only rename the same thing. The value comes from the calling workflow, not from untrusted event data, so it is only dangerous if a caller pastes github.event.* or branch names into 'cmd' themselves. That is the caller's mistake, just as it would be in their own run: step. The entrypoint already says so in a comment. Elsewhere: the Dockerfile base image is already pinned by digest, and runs.args are passed as upstream had them (argv, no shell). No files were changed.

### Iteration 3

**Fixes applied:** script-injection

**Notes:**

Removed `eval "$1"` from github-action/entrypoint.sh. The cmd input is now split into arguments with xargs, which respects quotes ('...' and "..." are honoured), and is run directly via `xargs -r sh -c '"$@"' sh`, so nothing in the value is evaluated as shell code. An unmatched quote now fails the step instead of silently dropping arguments. The script stays POSIX sh because the busybox-based yq image may not have bash, and it is marked executable. action.yml and the Docker args are unchanged. Behavior change: because cmd is no longer run by a shell, pipes, redirects, ';' chains and $VAR expansion in it now reach yq as literal text. Any caller that relied on those must do the redirect or pipe in its own run step. This was not tested in a container: it assumes the image's busybox xargs handles quotes the same way GNU xargs does. If a command fails, xargs reports exit code 123 instead of the command's own code, but the step still fails.

