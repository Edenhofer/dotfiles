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
# Link the bash configration file
ln -s /etc/bash.bashrc $(pwd)/bash.bashrc

# Link the inputrc
ln -s /etc/inputrc $(pwd)/inputrc

# Link the vim (vi improved) configuration file
ln -s /etc/vimrc $(pwd)/vimrc

# Link the GNU screen configuration file
ln -s /etc/screenrc $(pwd)/screenrc

# Link the color schemes for listing files
ln -s /etc/dircolors $(pwd)/dircolors
```

* Use the files for a single user only
```bash
# Link the bash configration file
ln -s ~/.bashrc $(pwd)/bash.bashrc

# Link the inputrc
ln -s ~/.inputrc $(pwd)/inputrc

# Link the vim (vi improved) configuration file
ln -s ~/.vimrc $(pwd)/vimrc

# Link the GNU screen configuration file
ln -s ~/.screenrc $(pwd)/screenrc

# Link the color schemes for listing files
ln -s ~/.dircolors $(pwd)/dircolors
```

## See also

* [Arch Build System](https://github.com/Edenhofer/abs) My github repo for tracking AUR packages is designed to be build upon. It contains useful commit hooks with the basics being automated and furthermore provides a utiliy to speedily upload packages to the AUR. It does so by utilizing the power of git-subtree's.

## Author

Gordian Edenhofer <gordian.edenhofer@gmail.com>

## License

Unless otherwise stated, the files in this project may be distributed under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or any later version. This work is distributed in the hope that it will be useful, but without any warranty; without even the implied warranty of merchantability or fitness for a particular purpose. See [version 2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html) and [version 3] (https://www.gnu.org/copyleft/gpl-3.0.html) of the GNU General Public License for more details.
