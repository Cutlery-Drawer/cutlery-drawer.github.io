make: test

test: test-darwin test-win32 test-linux

test-darwin test-win32 test-linux:
	set -- "$@"; ./run-as.sh "$${1#test-}"

clean:
	rm -rf coverage

.PHONY: test clean
