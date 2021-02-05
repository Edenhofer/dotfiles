" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages.
runtime! archlinux.vim
" Move around code blocks in e.g. Julia
runtime macros/matchit.vim

call plug#begin('~/.vim/plugged')
Plug 'editorconfig/editorconfig-vim'
Plug 'jamessan/vim-gnupg'
Plug 'mhinz/vim-signify'  " VCS sign indicators

if has('nvim')
	Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
	Plug 'Shougo/deoplete.nvim'
endif
Plug 'deoplete-plugins/deoplete-jedi'
Plug 'JuliaEditorSupport/julia-vim'

Plug 'dense-analysis/ale'
Plug 'tpope/vim-fugitive'  " Fancy git commands
Plug 'ludovicchabant/vim-gutentags'
Plug 'morhetz/gruvbox'

Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'

Plug 'vim-airline/vim-airline'
Plug 'KeitaNakamura/tex-conceal.vim', {'for': 'tex'}
Plug 'lervag/vimtex'

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
let g:ale_python_pylint_options = '--disable=line-too-long,bad-continuation,too-many-locals,too-few-methods,too-few-public-methods,invalid-name,wrong-import-order,wrong-import-position,import-outside-toplevel,missing-module-docstring,no-else-return'
let g:ale_python_flake8_options = '--ignore=E501,E122,E123,E124,E402,W503,W504'
" Enable the deoplete auto-completion framework
let g:deoplete#enable_at_startup = 1
" Make doc-strings work again in deoplete + Jedi
let g:deoplete#sources#jedi#show_docstring = 1
" Do not pollute projects with .ctags files
let g:gutentags_cache_dir = "~/.cache/ctags/"
" Enable snipMate compatibility feature.
let g:neosnippet#enable_snipmate_compatibility = 1
let g:neosnippet#snippets_directory = "~/.vim/plugged/vim-snippets/snippets/"
let g:tex_flavor = 'latex'
" Enable automatic LaTeX to Unicode substitution in Julia
let g:latex_to_unicode_keymap = 1
" Enable conceal features
let g:tex_conceal="abdgm"

" Define how concealed text is treated (default: 0, i.e. no conceal)
autocmd FileType tex,markdown setlocal conceallevel=2

set updatetime=100  " Plug-in update-time

set signcolumn=yes  " Set the sign column to always-on

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

" Define an enable switch for hybrid line numbers
set number relativenumber
set nu rnu
" Use absolute line numbers in non-focused buffers
augroup numbertoggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
	autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
augroup END

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

" Search for selection in visual mode via `//`
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Select the first, not the last suggestion by remapping {Shift-,}Tab
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><s-TAB> pumvisible() ? "\<C-p>" : "\<s-TAB>"

" Remaps inspired from GUI apps
inoremap <C-s> <esc>:w<CR>
noremap <C-s> <esc>:w<CR>
noremap <C-q> <esc>:q<CR>
