#!/bin/sh
set -e

# Print a colourful "==> $1"
title(){
	set -- "$1" "`tput setaf 4`" "`tput bold`" "`tput sgr0`"
	printf >&2 '%s==>%s %s%s%s\n' "$2" "$4" "$3" "$1" "$4"
}

# Colon-delimited list of currently-open folds
foldStack=

# Begin a collapsible folding region
# - Arguments: [id] [label]?
startFold(){
	if [ "$TRAVIS_JOB_ID" ]; then
		printf 'travis_fold:start:%s\r\e[0K' "$1"
	elif [ "$GITHUB_ACTIONS" ]; then
		set -- "$1" "${2:-$1}"
		set -- "`printf %s "$1" | sed s/:/꞉/g`" "$2"
		printf '\e[31mPushing %s...\e[39m\n' "$1" >&2
		foldStack="$1:$foldStack"
		printf '\e[31mStack is now \e[4m%s\e[24;39m\n' "$foldStack" >&2
		printf '::group::%s\n' "$2"
	fi
}

# Close a named folding region
# - Arguments: [id]?
endFold(){
	if [ "$TRAVIS_JOB_ID" ]; then
		printf 'travis_fold:end:%s\r\e[0K' "$1"
	elif [ "$GITHUB_ACTIONS" ]; then
		if [ $# -eq 0 ]; then
			set -- "${foldStack%%:*}"
			printf '\e[31mNo argument; defaulting to \e[4m%s\e[24;39m\n' "$1"
		fi
		printf '\e[31mEnd of fold "%s"\e[39m\n' "$1" >&2
		while [ "$foldStack" ] && [ ! "$1" = "${foldStack%%:*}" ]; do
			printf '\e[31mPopping %s...\e[39m\n' "$1" >&2
			set -- "${foldStack%%:*}"
			foldStack="${foldStack#*:}"
			printf '\e[31mStack is now \e[4m%s\e[24;39m\n' "$foldStack" >&2
			printf '::endgroup::\n'
		done
	fi
}


startFold 'diagnostics' 'Dumping diagnostic info and shit'
	startFold 'location' 'CWD and PATH'
		echo "\$PWD:  $PWD"
		echo "\$PATH: $PATH"
	endFold 'location'

	startFold 'ls-cwd'
		echo "ls -alh"
		ls -alh
	endFold 'ls-cwd'

	startFold 'ls-defs' 'Variable and function definitions'
		set

endFold 'diagnostics'
exit

curl -sL https://git.io/fji1w | sh
