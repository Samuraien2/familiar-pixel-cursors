PREFIX ?= /usr
DESTDIR ?=

familiar-pixel-cursors: all.png generate.sh
	@./generate.sh

install: familiar-pixel-cursors
	install -d $(DESTDIR)$(PREFIX)/share/icons
	cp -rv $< $(DESTDIR)$(PREFIX)/share/icons/
