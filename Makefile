all:
	@ echo "make all"

coverage:
	@ echo "make coverage"

install:
	@ echo "make install"
	node --version
	npm --version

.PHONY: all coverage install
