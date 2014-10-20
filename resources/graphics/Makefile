all:
	zsh -c '$(MAKE) plane-{red,green}-{0000..0035}.png'
plane-red-%.png: plane-%.png
	convert $< -fill red -colorize 50% $@
plane-green-%.png: plane-%.png
	convert $< -fill green -colorize 50% $@

