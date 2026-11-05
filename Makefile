familiar-pixel-cursors: all.png generate.sh
	@./generate.sh

install: familiar-pixel-cursors
	@rm -rf /usr/share/icons/$<
	@cp -rv $< /usr/share/icons/
