# README #

*Fysplane* is a wacky dogfighter made in Lua with the LÖVE framework. It uses real physics for simulating the planes' physics, but something is wrong so the planes are nearly impossible to fly.

### Installation

1. Get LÖVE 0.9.1 from your package manager or from http://love2d.org/.
2. `git clone git@bitbucket.org:mikko_ahlroth/fysplane.git`.
3. `cd /path/to/fysplane; love .` or drag the fysplane directory on LÖVE's Baby Inspector window.

For Ubuntu you can find a PPA if you like to install random stuff from the Internet:

    sudo apt-add-repository ppa:bartbes/love-stable &&
    sudo apt-get update &&
    sudo apt-get install love

### Special keys

* Ctrl-R to respawn both players, useful if you get stuck.
* Ctrl-D to toggle debug lines.
* In the start screen, press C to start playing with AI instead.