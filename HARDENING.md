<!-- markdownlint-disable -->

# Hardening Report: mikefarah--yq/v4.54.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **mikefarah--yq/v4.54.1** was hardened automatically. 1 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): action.yml passes `${{ inputs.cmd }}` as runs.args to the Docker image mikefarah/yq:4-githubaction. That image is built from github-action/Dockerfile, which runs ENTRYPOINT ["/entrypoint.sh"]. The script runs its first argument through the shell with `RESULT=$(eval "$1")`. So whatever text reaches the `cmd` input runs as a shell command inside the container. That includes text built from attacker-controlled context such as PR titles or branch names. This line runs the args through a shell, so it is reported here rather than the args list. Running a command is what the action is designed to do. Callers must never build `cmd` from untrusted input. A safer design would call `yq` directly with a fixed argv instead of using eval.

Locations:

- `github-action/entrypoint.sh:4`

## Iteration Notes

### Iteration 1

**Notes:**

No changes made. The script-injection finding is about `eval "$1"` in github-action/entrypoint.sh, which runs the `cmd` input as a shell command. That is what the action is for: `cmd` is documented as 'The Command which should be run', and users depend on shell features like quoting, pipes and redirects. Also, action.yml runs the prebuilt image docker://mikefarah/yq:4-githubaction, which is already pinned by sha256 digest, not the local Dockerfile, so editing entrypoint.sh would not change runtime behavior. Docker runs.args are passed as argv with no shell and are kept exactly as upstream wrote them. To stay safe, callers must never build `cmd` from untrusted context (PR titles, branch names, etc.). Pass such values through env: in a separate step, or avoid them. This is an accepted, by-design risk.

### Iteration 2

**Notes:**

I left the script-injection finding unfixed on purpose. The only change I made is a warning in the description of the cmd input.

Why I didn't apply the suggested fix:
1. The cmd input is meant to be a shell command. Upstream's documented usage is things like `yq -i '.a.b = "x"' file.yaml`, which needs shell quote handling, and people also use redirects and pipes. Running yq directly with an argument list would break that usage, so a fix would change what the action does rather than harden it. This works the same way as putting the input straight into a `run:` step: the calling workflow decides what goes into cmd.
2. action.yml runs the prebuilt image `docker://mikefarah/yq:4-githubaction`, pinned by digest. github-action/entrypoint.sh in this repo is not the script that runs, so editing it would have no effect. Building the image from the local Dockerfile instead would change how the action is delivered.

What I changed: the cmd input description now says the value is run as shell code and that untrusted values (PR titles, branch names, issue bodies) must be passed through env and referenced as variables, never pasted into cmd directly.

The next analysis pass will probably raise this finding again, since the eval is still there.

### Iteration 3

**Fixes applied:** script-injection

**Notes:**

github-action/entrypoint.sh: replaced `RESULT=$(eval "$1")` with a split that honours shell-style quotes but runs nothing: `printf '%s' "$1" | xargs -r sh -c 'exec "$@"' sh`. Before that, `printf '%s' "$1" | xargs -r true` makes the step fail on an unmatched quote. The script is still POSIX sh and works with the busybox shell in the Alpine yq image. The documented usage `yq -i '.foo.bar = "cool"' 'config.yml'` still splits into the same arguments. A failing command still fails the step (set -e catches xargs's non-zero exit). action.yml: runs.image changed from the prebuilt docker://mikefarah/yq:4-githubaction image to github-action/Dockerfile. The prebuilt image has the old eval entrypoint built in, so it would have kept the hole open; the Dockerfile's base image is already pinned by digest. The cmd input's description now says the command is not run through a shell. Behaviour change: pipes, redirects, command substitution and $VAR expansion inside cmd no longer work. Use yq's env() operator to read environment variables. Runs.args stay as upstream had them. Not tested here.

