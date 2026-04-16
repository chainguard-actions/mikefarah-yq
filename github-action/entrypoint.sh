#!/bin/sh -l
set -e
echo "::debug::\$cmd: $1"
RESULT=$(eval "$1")
echo "::debug::\$RESULT: $RESULT"
# updating from 
# https://github.com/orgs/community/discussions/26288#discussioncomment-3876281
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-output-parameter
delimiter=$(cat /proc/sys/kernel/random/uuid)
safe_result=$(printf '%s' "${RESULT}" | tr -d '\n\r')
echo "result<<${delimiter}" >> "${GITHUB_OUTPUT}"
echo "${safe_result}" >> "${GITHUB_OUTPUT}"
echo "${delimiter}" >> "${GITHUB_OUTPUT}"
