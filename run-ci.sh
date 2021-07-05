#!/bin/sh
set -e

eval "`curl -sL https://git.io/fji1w`"

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
			`\x1B[32m${x}\x1B[39m\x1B[2m=\x1B[36m\x27\x1B[22m${process.env[x]}\x1B[2m\x27\x1B[0m`
		).join("\n")'

endFold 'diagnostics'
