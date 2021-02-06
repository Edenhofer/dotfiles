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

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
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
let g:tex_conceal = "abdgm"
" Employ `ripgrep` for an awesome fuzzy search (NOTE, requires `ripgrep`!)
let $FZF_DEFAULT_COMMAND = "rg --files --hidden --ignore-vcs --glob '!.git'"
let g:fzf_commands_expect = 'alt-enter'

" Define how concealed text is treated (default: 0, i.e. no conceal)
au FileType tex,markdown setlocal conceallevel=2
au FileType gitcommit set tw=72  " automatically wrap long commit messages
au FileType gitcommit setlocal spell

command! -bang -nargs=? -complete=dir Files
	\ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* GGrep
	\ call fzf#vim#grep(
	\	'git grep --line-number -- '.shellescape(<q-args>), 0,
	\	fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)
command! -bang -nargs=* Rg
	\ call fzf#vim#grep(
	\	'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
	\	fzf#vim#with_preview(), <bang>0)

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

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

" Enable pasting without replacing the register
vnoremap p "_dP

" Enable basic mouse support
set mouse=a
" Use the global clipboard for copy-pasting, a.k.a. yanking
set clipboard=unnamedplus

set hidden
" Define keyboard shortcuts for switching between buffers
nnoremap <C-h> <cmd>bprev<CR>
nnoremap <C-l> <cmd>bnext<CR>

" Spell checking
set spell
set spelllang=en_us,de_de

" Search for selection in visual mode via `//`
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Select the first, not the last suggestion by remapping {Shift-,}Tab
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><s-TAB> pumvisible() ? "\<C-p>" : "\<s-TAB>"

" Remaps inspired from GUI apps
noremap <c-o> <cmd>Files<CR>
noremap <c-p> <cmd>Commands<CR>
noremap <c-f> <cmd>Rg<CR>
inoremap <C-s> <cmd>w<CR>
noremap <C-s> <cmd>w<CR>
noremap <C-q> <cmd>q<CR>
noremap <C-k> <cmd>ALEHover<CR>
