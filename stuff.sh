#!/bin/sh
set -e

sgr(){
	# Treat no arguments as shorthand for `sgr 0`
	[ $# -gt 0 ] || set -- 0

	# Resolve FORCE_COLOUR variable
	if   [ "${FORCE_COLOR+1}"  ]; then set -- FORCE_COLOR  "$@"
	elif [ "${FORCE_COLOUR+1}" ]; then set -- FORCE_COLOUR "$@"
	else                               set -- ""           "$@"
	fi

	# Resolve colour depth, if forced
	if [ "$1" ]; then
		case `eval "echo \"\\$$1\""` in
			''|1|true) shift; set -- 0 16       "$@" ;; # 16-colour support
			2)         shift; set -- 0 256      "$@" ;; # 256-colour support
			3)         shift; set -- 0 16000000 "$@" ;; # 16-million (“true colour”) support
			*)         shift; set -- 1 0        "$@" ;; # Invalid value; disable colours
		esac
	else
		# Resolve NO_COLOUR variable
		if   [ "${NO_COLOR+1}"  ]; then set -- 1 "$@"
		elif [ "${NO_COLOUR+1}" ]; then set -- 1 "$@"
		else                            set -- 0 "$@"
		fi
	fi

	# Do nothing if colours are suppressed
	[ "$1" = 1 ] && return || shift

	# IDEA: Gatekeep colour resolution based on forced colour depth; i.e., 16-colour
	# mode causes `38;5;10` (bright green) to degrade into `32` (ordinary green).
	shift

	printf '\033[%sm' "$*" | sed 's/  */;/g' | tr -d '\n'
}

# Quote command-line arguments for console display
argfmt(){
	while [ $# -gt 0 ]; do case $1 in *'
'*) printf \'; printf %s "$1" | sed s/\''/&\\&&/g'; printf \' ;;
	*) printf %s "$1" | sed ':x
	/^[]+:@^_[:alnum:][=[=]/.-][]~#+:@^_[:alnum:][=[=]/.-]*$/!{
		/^[]~#+:@^_[:alnum:][=[=]/.-]*[^]~#+:@^_[:alnum:][=[=]/.-][]~#+:@^_[:alnum:][=[=]/.-]*$/{
			/^--*.*=/!s/[^]~#+:@^_[:alnum:][=[=]/.-]/\\&/;;n;bx
		}; /'\''/! {s/^/'\''/;s/$/'\''/;n;bx
	}; s/[$"\\@]/\\&/g;s/^/"/;s/$/"/;}' ;;
	esac; shift; [ $# -eq 0 ] || printf ' '; done
}

cmdfmt(){
	set -- "`argfmt "$@"`"
	printf '<%s>\n'
	if [ "$GITHUB_ACTIONS" ]; then
		printf '[command]%s\n' "$1"
	else
		printf '%s$ %s%s\n' "`sgr 32`" "$1" "`sgr`"
	fi
}


# curl -sL https://git.io/fji1w > atom-ci.sh
# eval "`sed < atom-ci.sh -n '/^switchToProject$/q;p'`"

gzip < /usr/bin/sed | base64
cmdfmt curl --version
cmd curl --version
exit

sed '/^switchToProject$/{
	N;
	s/\n/\nset +x/
}' < atom-ci.sh | sh
