#!/bin/sh
set -e

case `uname -s` in Darwin)
	echo "com.apple.finder -> FavoriteTagNames:"
	defaults read com.apple.finder FavoriteTagNames || :
	echo "com.apple.Accessibility -> KeyRepeatDelay:"
	defaults read com.apple.Accessibility KeyRepeatDelay || :
	echo "com.apple.Accessibility -> KeyRepeatEnabled:"
	defaults read com.apple.Accessibility KeyRepeatEnabled || :
	echo "com.apple.Accessibility -> KeyRepeatInterval:"
	defaults read com.apple.Accessibility KeyRepeatInterval || :
	exit
;; esac

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
		printf 'travis_fold:start:%s\r\033[0K' "$1"
	elif [ "$GITHUB_ACTIONS" ]; then
		set -- "$1" "${2:-$1}"
		set -- "`printf %s "$1" | sed s/:/꞉/g`" "$2"
		printf '\033[31mPushing %s...\033[39m\n' "$1" >&2
		foldStack="$1:$foldStack"
		printf '\033[31mStack is now \033[4m%s\033[24;39m\n' "$foldStack" >&2
		printf '::group::%s\n' "$2"
	fi
}

# Close a named folding region
# - Arguments: [id]?
endFold(){
	if [ "$TRAVIS_JOB_ID" ]; then
		printf 'travis_fold:end:%s\r\033[0K' "$1"
	elif [ "$GITHUB_ACTIONS" ]; then
		if [ $# -eq 0 ]; then
			set -- "${foldStack%%:*}"
			printf '\033[31mNo argument; defaulting to \033[4m%s\033[24;39m\n' "$1"
		fi
		printf '\033[31mEnd of fold "%s"\033[39m\n' "$1" >&2
		while [ "$foldStack" ] && [ ! "$1" = "${foldStack%%:*}" ]; do
			printf '\033[31mPopping %s...\033[39m\n' "$1" >&2
			set -- "${foldStack%%:*}"
			foldStack="${foldStack#*:}"
			printf '\033[31mStack is now \033[4m%s\033[24;39m\n' "$foldStack" >&2
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
