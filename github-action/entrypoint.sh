#!/bin/sh -l
set -e
echo "::debug::\$cmd: $1"
# Do not eval the command: split it into arguments honoring quotes (as the
# shell would) and execute it directly, so shell metacharacters such as
# ';', '|', '&&', '$(...)' and backticks are passed as literal text.
# Fail on an unmatched quote instead of silently dropping arguments.
printf '%s' "$1" | xargs -r true
RESULT=$(printf '%s' "$1" | xargs -r sh -c 'exec "$@"' yq-action)
echo "::debug::\$RESULT: $RESULT"
# updating from 
# https://github.com/orgs/community/discussions/26288#discussioncomment-3876281
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-output-parameter
delimiter=$(cat /proc/sys/kernel/random/uuid)
echo "result<<${delimiter}" >> "${GITHUB_OUTPUT}"
echo "${RESULT}" >> "${GITHUB_OUTPUT}"
echo "${delimiter}" >> "${GITHUB_OUTPUT}"
