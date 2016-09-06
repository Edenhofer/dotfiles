# KISS dotfiles
This repo tracks my dotfiles for various programs I use on a daily basis. The aim is to provide a minimalistic set of features which strictly follow the KISS principle.

## Content
All files should be easily readable and self-explaining. However I would still like to highlight some specialities:

### Bashrc
* colored PS1
* vi mode keybindings is the default
* vim is the default editor
* aliases are only created if necessary: root won't have sudo-shortcuts, systemd aliases are only created if systemd is installed etc.
* couple of pacman aliases (Arch Linux only)
* some medium-sized functions, e.g.
	* anygrep: grep through more than just plain text (pdf, odf and more)
	* extract: decompress any archive

### Inputrc
* case insensitive tab-completion

### Vimrc
* search case-insensitive if the search-key is lowercasei only
* automatically indent

### Screenrc
* automatically detach
* search case-insensitive
* increased scrollbuffer
* different layouts:
	* one (defautl): classical one window layout
	* split: splitted layout

## Setup
You may use those cunfiguration files solely for inspiration or if you really like them you might even build on top of them. To move the the various files in place, I would recommend simply linking them instead of actually moving the file. Remember to not move the linked files afterwards without changing the links accordingly.

* Use the files as system wide defaults
```bash
# Link bash configuration file
ln -s $(pwd)/bash.bashrc /etc/bash.bashrc

# Link various scripts, not included in the bash configuration file
# PREFERABLY INSTALL THOSE SCRIPTS ON A PER USER BASIS!
ln -s $(pwd)/bin/* /usr/bin

# Link inputrc file
ln -s $(pwd)/inputrc /etc/inputrc

# Link vim (vi improved) configuration file
ln -s $(pwd)/vimrc /etc/vimrc

# Link GNU screen configuration file
ln -s $(pwd)/screenrc /etc/screenrc

# Link color schemes for listing files
ln -s $(pwd)/dircolors /etc/dircolors
```

* Use the files for a single user only
```bash
# Link bash configuration file
ln -s $(pwd)/bash.bashrc ~/.bashrc

# Link various scripts, not included in the bash configuration file
mkdir -p ~/bin && ln -s $(pwd)/bin/* ~/bin

# Link inputrc
ln -s $(pwd)/inputrc ~/.inputrc

# Link vim (vi improved) configuration file
ln -s $(pwd)/vimrc ~/.vimrc

# Link GNU screen configuration file
ln -s $(pwd)/screenrc ~/.screenrc

# Link color schemes for listing files
ln -s $(pwd)/dircolors ~/.dircolors
```

## See also

* [Arch Build System](https://github.com/Edenhofer/abs) My github repo for tracking AUR packages is designed to be build upon. It contains useful commit hooks with the basics being automated and furthermore provides a utiliy to speedily upload packages to the AUR. It does so by utilizing the power of git-subtree's.

## Author

Gordian Edenhofer <gordian.edenhofer@gmail.com>

## License

Unless otherwise stated, the files in this project may be distributed under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or any later version. This work is distributed in the hope that it will be useful, but without any warranty; without even the implied warranty of merchantability or fitness for a particular purpose. See [version 2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html) and [version 3] (https://www.gnu.org/copyleft/gpl-3.0.html) of the GNU General Public License for more details.
