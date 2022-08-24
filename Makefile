all:
	@ echo "make all"

coverage:
	@ echo "make coverage"

install:
	@ echo "make install"
	node --version
	npm --version
	npm install --quiet --no-save --no-package-lock

.PHONY: all coverage install
