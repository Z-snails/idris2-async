
IDRIS2_LIBDIR = $(shell idris2 --libdir)

.PHONY: install-support
install-support:
	install support/async.js $(IDRIS2_LIBDIR)/support/js/async.js

.PHONY: install
install:
	idris2 --install Inigo.ipkg

.PHONY: install-with-src
install-with-src:
	idris2 --install Inigo.ipkg
