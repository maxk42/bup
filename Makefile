PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man/man1

.PHONY: install uninstall test

install:
	@echo "Installing bup to $(BINDIR)..."
	install -d $(BINDIR)
	install -m 755 bup $(BINDIR)/bup
	@echo "Installing man page to $(MANDIR)..."
	install -d $(MANDIR)
	install -m 644 man/bup.1 $(MANDIR)/bup.1
	@echo "Done. Run 'bup --version' to verify."

uninstall:
	@echo "Removing bup from $(BINDIR)..."
	rm -f $(BINDIR)/bup
	rm -f $(MANDIR)/bup.1
	@echo "Done."

test:
	@./test-bup
