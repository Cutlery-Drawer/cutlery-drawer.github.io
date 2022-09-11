#!/bin/sh
set -e

case $1 in
	win32|linux|darwin) ;;
	*) printf >&2 'usage: %s [win32|linux|darwin]\n' "$0"; exit 2;;
esac

cmd=`printf '
	Object.defineProperty(process, "platform", {value: "%s"});
	import("./index.mjs");
' "$1"`

c8 --clean=false node -e "$cmd"
