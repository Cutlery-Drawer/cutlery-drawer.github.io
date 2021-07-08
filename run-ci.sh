#!/bin/sh
set -e

stat='stat -x'

# GNU stat(1) is verbose by default (and therefore doesn't grok the `-x` switch)
$stat / >/dev/null 2>&1 || stat=stat
which bash      || :
$stat /bin/bash || :

ls -alh /Users/runner/work/_temp/_runner_file_commands/ 2>/dev/null || :

if test -t 1
	then echo 'STDOUT is attached to a terminal'
	else echo 'STDOUT is NOT attached to a terminal'
fi
if test -t 2
	then echo 'STDERR is attached to a terminal'
	else echo 'STDERR is NOT attached to a terminal'
fi

printf 'Foo\033[1GBar\n'
printf '[ABC\b\b\b]\n'
printf '[command]/bin/echo "This just gets worse and worse"'
printf '\nFoo\n\r::warning::Foo bar, etc'
exit 0

exec 3>&1; curl -sL https://git.io/fji1w | { sh 2>&1 >&3 3>&- || exit $?; } \
| grep -v 3>&- 'Electron: Loading non-context-aware native module in renderer:'
exec 3>&-
