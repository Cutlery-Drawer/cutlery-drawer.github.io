#!/bin/sh
set -e

# ASCII escape character (U+001B)
esc=`printf '\033'`

# Print a colourful "==> $1"
title(){
	set -- "$1" "$esc[34m" "$esc[1m" "$esc[0m"
	printf '%s==>%s %s%s%s\n' "$2" "$4" "$3" "$1" "$4"
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
		foldStack="$1:$foldStack"
		
		# FIXME: GitHub Actions don't support nested groups. Degrade gracefully.
		case $foldStack in *:*:*) title "$2" ;; *) printf '::group::%s\n' "$2" ;; esac
		
		return
	fi
	[ -z "$2" ] || title "$2"
}

# Close a named folding region
# - Arguments: [id]?
endFold(){
	if [ "$TRAVIS_JOB_ID" ]; then
		printf 'travis_fold:end:%s\r\033[0K' "$1"
	elif [ "$GITHUB_ACTIONS" ]; then
		[ $# -gt 0 ] || set -- "${foldStack%%:*}"
		while [ "$foldStack" ] && [ ! "$1" = "${foldStack%%:*}" ]; do
			set -- "${foldStack%%:*}"
			foldStack="${foldStack#*:}"
			# FIXME: Same issue/limitation as `startFold()`
			case $foldStack in *:*) ;; *) printf '::endgroup::\n' ;; esac
		done
	fi
}

if [ -f /home/travis/.travis/functions ]; then
	startFold 'fuck' 'Catting functions'
		cat /home/travis/.travis/functions
	endFold
elif [ "$TRAVIS_JOB_ID" ]; then
	echo 'No such file: /home/travis/.travis/functions'
fi

startFold 'diagnostics' 'Dumping diagnostic info and shit'
	startFold 'location' 'CWD and PATH'
		echo "\$PWD:  $PWD"
		echo "\$PATH: $PATH"
	endFold 'location'

	startFold 'ls-cwd'
		ls -alh
	endFold 'ls-cwd'

	startFold 'ls-defs' 'Variable and function definitions'
		node -p 'Object.keys(process.env).sort().map(x =>
			`\x1B[38;5;10m${x}\x1B[39m\x1B[2m=\x1B[38;5;14m\x27\x1B[22m${process.env[x]}\x1B[2m\x27\x1B[0m`
		).join("\n")'

endFold 'diagnostics'
exit

curl -sL https://git.io/fji1w | sh
