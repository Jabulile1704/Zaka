#!/usr/bin/env bash
#
# Reads a pull request body on stdin and prints the issue numbers it closes,
# one per line: "Closes #24", "fixes #5", "Resolved #12" and so on.
#
# The body is untrusted text, so it is only ever matched against a pattern,
# never evaluated.

set -euo pipefail

grep -oiE '\b(close[sd]?|fix(e[sd])?|resolve[sd]?):? +#[0-9]+' \
  | grep -oE '[0-9]+$' \
  | sort -un \
  || true
