" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages.
runtime! archlinux.vim

set tabstop=4       " Number of spaces that a <Tab> in the file counts for.
set shiftwidth=4    " Number of spaces to use for each step of (auto)indent.
set showcmd         " Show (partial) command in status line.
set number          " Show line numbers.
set hlsearch        " When there is a previous search pattern, highlight all its matches.
set incsearch       " While typing a search command, show immediately where the so far typed pattern matches.
set ignorecase      " Ignore case in search patterns.
set smartcase       " Override the 'ignorecase' option if the search pattern
au FileType gitcommit set tw=72 " automatically wrap long commit messages
au FileType gitcommit setlocal spell
"set autoindent      " Copy indent from current line when starting a new line
"set textwidth=79     " Maximum width of text that is being inserted.
"set formatoptions=c,q,r,t " How automatic formatting is to be done.
                    " c         Auto-wrap comments using textwidth, inserting
                    "           the current comment leader automatically.
                    " q         Allow formatting of comments with "gq".
                    " r         Automatically insert the current comment leader
                    "           after hitting <Enter> in Insert mode.
                    " t         Auto-wrap text using text width (does not apply to comments)
set ruler           " Show the line and column number of the cursor position, separated by a comma.
set background=light " Specify either "dark" or "light"
set mouse-=a        " Enable the use of the mouse.
"filetype plugin indent on " Auto indent new lines
syntax on           " Enable or disable syntax highlighting
set linebreak       " Visual line wrapping
"set foldmethod=indent
"set breakindentopt=shift:4
set spelllang=en,de " Enable spell checking in multiple languages
