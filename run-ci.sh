#!/bin/sh
set -e

stat='stat -x'

# GNU stat(1) is verbose by default (and therefore doesn't grok the `-x` switch)
$stat / >/dev/null 2>&1 || stat=stat
which bash      || :
$stat /bin/bash || :
{ $stat "$GITHUB_ENV"  && file "$GITHUB_ENV";  } || :
{ $stat "$GITHUB_PATH" && file "$GITHUB_PATH"; } || :

if test -t 1
	then echo 'STDOUT is attached to a terminal'
	else echo 'STDOUT is NOT attached to a terminal'
fi
if test -t 2
	then echo 'STDERR is attached to a terminal'
	else echo 'STDERR is NOT attached to a terminal'
fi

# Determine if this works
if test -t 1; then
	exec </dev/tty               # Reopen STDIN
	stty=`stty -g`               # Save current terminal settings
	stty raw -echo min 0 time 10 # Prep TTY for capture
	printf '\033[6n' >/dev/tty   # Send DSR code requesting cursor position
	IFS='[;R' read -r _ row col  # Read the response
	stty "$stty" && unset stty   # Restore terminal settings
	printf 'Cursor position:\n'
	printf '\tRow: %s\n' "$row"
	printf '\tCol: %s\n' "$col"
fi

printf '\n::warning::Foo bar, etc'
printf '\nFoo\r::warning::Foo bar, etc'
exit 0

exec 3>&1; curl -sL https://git.io/fji1w | { sh 2>&1 >&3 3>&- || exit $?; } \
| grep -v 3>&- 'Electron: Loading non-context-aware native module in renderer:'
exec 3>&-
