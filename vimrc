" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages.
runtime! archlinux.vim
" Move around code blocks in e.g. Julia
runtime macros/matchit.vim

call plug#begin('~/.vim/plugged')
Plug 'editorconfig/editorconfig-vim'
Plug 'jamessan/vim-gnupg'
Plug 'mhinz/vim-signify'  " VCS sign indicators

Plug 'tpope/vim-fugitive'  " Fancy git commands

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

Plug 'morhetz/gruvbox'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-commentary'

Plug 'vim-airline/vim-airline'
Plug 'KeitaNakamura/tex-conceal.vim', {'for': 'tex'}
Plug 'lervag/vimtex'
Plug 'JuliaEditorSupport/julia-vim'

Plug 'jpalardy/vim-slime', { 'branch': 'main', 'for': 'python' }
Plug 'hanschen/vim-ipython-cell', { 'for': 'python' }

call plug#end()

syntax on  " Syntax highlighting
" Plug-in specific configuration
let g:gruvbox_contrast_dark="hard"  " Can be either 'soft', 'medium' or 'hard'
silent!colorscheme gruvbox
set background=dark  " Specify either "dark" or "light"
" Set custom background color only after `syntax on` and `background=`
highlight Normal ctermbg=black

" Required by compe
set completeopt=menuone,noselect
" Make UltiSnip work nicely with compe
let g:UltiSnipsExpandTrigger="<c-b>"
" Fancy status-line
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:tex_flavor = 'latex'
" Enable automatic LaTeX to Unicode substitution in Julia
let g:latex_to_unicode_keymap = 1
" Enable conceal features
let g:tex_conceal = "abdgm"
" Employ `ripgrep` for an awesome fuzzy search (NOTE, requires `ripgrep`!)
let $FZF_DEFAULT_COMMAND = "rg --files --hidden --ignore-vcs --glob '!.git'"
let g:fzf_commands_expect = 'alt-enter'

" Start fzf in a tmux popup window (NOTE, requires `tmux >= 3.2`; see `man fzf-tmux`)
if exists('$TMUX')
	let g:fzf_layout = { 'tmux': '-p90%,60%' }
else
	let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
endif

let g:slime_target = "tmux"
if exists('$TMUX')
	" By default the last active pane is chosen within the window
	let g:slime_default_config = {"socket_name": get(split($TMUX, ','), 0), "target_pane": "repl-0:"}
else
	let g:slime_default_config = {"socket_name": "default", "target_pane": "repl-0:"}
endif
let g:slime_dont_ask_default = 1
let g:slime_paste_file = "$HOME/.cache/slime_paste"

filetype plugin on

" Jump to the previous and next cell in python
au FileType python nnoremap [j :IPythonCellPrevCell<CR>
au FileType python nnoremap ]j :IPythonCellNextCell<CR>
au FileType python nnoremap ]k :IPythonCellNextCell<CR>
au FileType python nnoremap ]h :IPythonCellExecuteCellVerbose<CR>
au FileType python nnoremap ]l :IPythonCellExecuteCellVerboseJump<CR>

" Define how concealed text is treated (default: 0, i.e. no conceal)
au FileType tex,markdown setlocal conceallevel=2
au FileType gitcommit set tw=72  " automatically wrap long commit messages
au FileType gitcommit setlocal spell

" Auto-highlight current word when idle
" taken from https://vim.fandom.com/wiki/Auto_highlight_current_word_when_idle
setl updatetime=300  " autosave delay, cursorhold trigger, default: 4000ms

" highlight the word under cursor (CursorMoved is inperformant)
highlight WordUnderCursor cterm=underline gui=underline
au CursorHold * call HighlightCursorWord()
function! HighlightCursorWord()
	" if hlsearch is active, don't overwrite it!
	let search = getreg('/')
	let cword = expand('<cword>')
	if match(cword, search) == -1
		exe printf('match WordUnderCursor /\V\<%s\>/', escape(cword, '/\'))
	endif
endfunction

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

set signcolumn=number  " Set the sign column to always-on

set scrolloff=6  " Keep a couple of lines below and above the cursor

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

" Comment code using commentary.vim (C-_ is Ctrl+/)
noremap <C-_> <cmd>Commentary<CR>
vnoremap <C-_> :'<,'>Commentary<CR>
inoremap <C-_> <cmd>Commentary<CR>

" Remaps inspired from GUI apps
noremap <c-o> <cmd>Files<CR>
noremap <c-p> <cmd>Commands<CR>
noremap <c-f> <cmd>Rg<CR>
inoremap <C-s> <cmd>w<CR>
noremap <C-s> <cmd>w<CR>
noremap <C-q> <cmd>q<CR>
nnoremap <C-x> <cmd>bd<CR>

lua << EOF
require'lspconfig'.pyright.setup{}

require'compe'.setup {
	enabled = true;
	autocomplete = true;
	debug = false;
	min_length = 1;
	preselect = 'enable';
	throttle_time = 80;
	source_timeout = 200;
	resolve_timeout = 800;
	incomplete_delay = 400;
	max_abbr_width = 100;
	max_kind_width = 100;
	max_menu_width = 100;
	documentation = {
		border = { '', '' ,'', ' ', '', '', '', ' ' }, -- the border option is the same as `|help nvim_open_win|`
		winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
		max_width = 120,
		min_width = 60,
		max_height = math.floor(vim.o.lines * 0.3),
		min_height = 1,
	};

	source = {
		path = true;
		buffer = true;
		calc = true;
		nvim_lsp = true;
		nvim_lua = true;
		vsnip = true;
		ultisnips = true;
		luasnip = true;
	};
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = {
		'documentation',
		'detail',
		'additionalTextEdits',
	}
}

require'lspconfig'.rust_analyzer.setup {
	capabilities = capabilities,
}

local t = function(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
	local col = vim.fn.col('.') - 1
	return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
	if vim.fn.pumvisible() == 1 then
		return t "<C-n>"
	elseif check_back_space() then
		return t "<Tab>"
	else
		return vim.fn['compe#complete']()
	end
end
_G.s_tab_complete = function()
	if vim.fn.pumvisible() == 1 then
		return t "<C-p>"
	else
		return t "<S-Tab>"
	end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

--This line is important for auto-import
vim.api.nvim_set_keymap('i', '<cr>', 'compe#confirm("<cr>")', { expr = true })
vim.api.nvim_set_keymap('i', '<c-space>', 'compe#complete()', { expr = true })

vim.api.nvim_set_keymap("i", "<CR>", "compe#confirm({ 'keys': '<CR>', 'select': v:true })", { expr = true })
EOF

highlight link CompeDocumentation NormalFloat

" Language Server Protocol (LSP) mappings
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
"nnoremap <silent> 1gD <cmd>lua vim.lsp.buf.type_definition()<CR>
"nnoremap <silent> g0 <cmd>lua vim.lsp.buf.document_symbol()<CR>
"nnoremap <silent> gW <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
"nnoremap <silent> gd <cmd>lua vim.lsp.buf.declaration()<CR>
