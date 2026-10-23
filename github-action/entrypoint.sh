#!/bin/sh -l
set -e
echo "::debug::\$cmd: $1"
# Split the command into arguments honoring shell-style quotes (so
# `yq -i '.foo.bar = "cool"' 'config.yml'` keeps working) WITHOUT evaluating it:
# ';', '|', '&&', '$(...)', backticks and variable references in the value are
# passed through as literal argument text instead of being run by a shell.
# Fail on an unmatched quote rather than silently dropping arguments.
printf '%s' "$1" | xargs -r true
RESULT=$(printf '%s' "$1" | xargs -r sh -c 'exec "$@"' sh)
echo "::debug::\$RESULT: $RESULT"
# updating from 
# https://github.com/orgs/community/discussions/26288#discussioncomment-3876281
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-output-parameter
delimiter=$(cat /proc/sys/kernel/random/uuid)
echo "result<<${delimiter}" >> "${GITHUB_OUTPUT}"
echo "${RESULT}" >> "${GITHUB_OUTPUT}"
echo "${delimiter}" >> "${GITHUB_OUTPUT}"
