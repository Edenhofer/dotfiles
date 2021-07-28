# KISS dotfiles

This repo tracks my dotfiles for various programs I use on a daily basis. The aim is to provide a minimalistic set of features which strictly follow the KISS principle.

## Content

All files should be easily readable and self-explaining. However some features are still worth mentioning:

### Bashrc

* vi mode keybindings is the default
* (n)vim is the default editor
* aliases are only created if necessary: root won't have sudo-shortcuts, systemd aliases are only created if systemd is installed etc.
* couple of pacman aliases (Arch Linux only)
* some medium-sized scripts, e.g.
	* anygrep: grep through more than just plain text (pdf, odf and more)
	* extract: decompress any archive
	* videocmd: invoke ffmpeg and youtube-dl options through a text configuration file

### Zshrc

* sporting every feature of the bashrc
* powerful auto-completion
* git status indicator
* lazy-load plug-ins like syntax highlighting

### Inputrc

* case insensitive tab-completion

### Vimrc and NeoVimrc

* identical configuration for both editors

### Screenrc and Tmuxrc

* GNU screen style meta-key
* windows starting at 1

## Setup

The setup is intended to be feature complete and provide all necessities for getting stuff done. Feel free to take inspiration from whatever part you may find interesting. To enable certain or all configurations for your user, run:

```bash
ln -s $(pwd)/zshrc ~/.zshrc
ln -s $(pwd)/bash.bashrc ~/.bashrc
mkdir -p ~/bin && ln -s $(pwd)/bin/* ~/bin
ln -s $(pwd)/inputrc ~/.inputrc

ln -s $(pwd)/vimrc ~/.vimrc
ln -s $(pwd)/vimrc ~/.config/nvim/init.vim

ln -s $(pwd)/screenrc ~/.screenrc
ln -s $(pwd)/tmux.conf ~/.tmux.conf
```

### Vim-Plug

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

### Tmux Plugin Manager

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### NeoVim

```
" Just source ~/.vimrc
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
```

## See also

* [Arch Build System](https://github.com/Edenhofer/abs) My github repo for tracking AUR packages is designed to be a perfect template to build upon. It contains useful commit hooks with the basics being automated and furthermore provides a utility to speedily upload packages to the AUR. Packages are managed via git-subtree's.

## Author

Gordian Edenhofer <gordian.edenhofer@gmail.com>
