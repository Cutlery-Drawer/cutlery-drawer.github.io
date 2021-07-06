#!/bin/sh
set -e

exec 3>&1; curl -sL https://git.io/fji1w | { sh 2>&1 >&3 3>&- || exit $?; } \
| grep -v 3>&- 'Electron: Loading non-context-aware native module in renderer:'
exec 3>&-
