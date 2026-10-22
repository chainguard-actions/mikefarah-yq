#!/bin/sh -l

echo "$1"
# The 'cmd' input is split into arguments with quote-aware tokenization
# (busybox xargs honours '...' and "..." quoting) and executed directly,
# WITHOUT eval: shell metacharacters such as ';', '|', '$(...)' or backticks
# in the value are passed to the command as literal argument text and are
# never interpreted as shell code.
if [ -n "$1" ]; then
  # Fail on an unmatched quote instead of silently dropping arguments.
  printf '%s' "$1" | xargs -r true || { echo "Invalid cmd: unmatched quote" >&2; exit 1; }
  printf '%s' "$1" | xargs -r sh -c '"$@"' sh
fi
