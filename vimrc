" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages.
runtime! archlinux.vim

call plug#begin('~/.vim/plugged')
Plug 'editorconfig/editorconfig-vim'
Plug 'jamessan/vim-gnupg'

if has('nvim')
	Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
	Plug 'Shougo/deoplete.nvim'
endif
Plug 'deoplete-plugins/deoplete-jedi'

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'morhetz/gruvbox'
Plug 'tpope/vim-fugitive'  " Fancy git commands
Plug 'mhinz/vim-signify'  " VCS sign indicators
Plug 'vim-airline/vim-airline'
Plug 'dense-analysis/ale'
Plug 'ludovicchabant/vim-gutentags'

call plug#end()
" Plug-in specific configuration
let g:gruvbox_contrast_dark="hard"  " Can be either 'soft', 'medium' or 'hard'
silent!colorscheme gruvbox
" Fancy status-line
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
" Fancy syntax error checking with ALE
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%::%code%]'
let g:ale_python_pylint_options = '--disable=line-too-long,too-many-locals,too-few-methods,invalid-name,wrong-import-order,wrong-import-position,import-outside-toplevel,missing-module-docstring'
let g:ale_python_flake8_options = '--ignore=E501,E124'
" Enable the deoplete auto-completion framework
let g:deoplete#enable_at_startup = 1
" Make doc-strings work again in deoplete + Jedi
let g:deoplete#sources#jedi#show_docstring = 1
" Do not pollute projects with .ctags files
let g:gutentags_cache_dir = "~/.cache/ctags/"

set updatetime=100  " Plug-in update-time

set background=dark  " Specify either "dark" or "light"

set tabstop=4     " Number of spaces that a <Tab> in the file counts for.
set shiftwidth=4  " Number of spaces to use for each step of (auto)indent.
set showcmd       " Show (partial) command in status line.

" Configure search
set hlsearch    " Highlight all matches of a previous search
set incsearch   " Show immediately where the so far typed pattern matches
set ignorecase  " Ignore case in search patterns
set smartcase   " Override the 'ignorecase' option if the search pattern contains uppercase

au FileType gitcommit set tw=72  " automatically wrap long commit messages
au FileType gitcommit setlocal spell

set diffopt+=iwhite " Ignore white space

set linebreak       " Visual line wrapping
syntax on           " Enable or disable syntax highlighting

" Enable basic mouse support
set mouse=a
" Use the global clipboard for copy-pasting, a.k.a. yanking
set clipboard=unnamedplus

set hidden
" Define keyboard shortcuts for switching between buffers
nnoremap <C-h> :bprev<CR>
nnoremap <C-l> :bnext<CR>

" Spell checking
set spell
set spelllang=en_us,de_de

" Define an enable switch for hybrid line numbers
set number relativenumber
set nu rnu
" Use absolute line numbers in non-focused buffers
augroup numbertoggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
	autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
augroup END

" Search for selection in visual mode via `//`
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Select the first, not the last suggestion by remapping {Shift-,}Tab
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><s-TAB> pumvisible() ? "\<C-p>" : "\<s-TAB>"
