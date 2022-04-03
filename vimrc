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
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

Plug 'morhetz/gruvbox'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " Update parsers on update
Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins' }

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

syntax on  " Syntax highlighting; mostly superseded by tree-sitter
" Plug-in specific configuration
let g:gruvbox_contrast_dark="hard"  " Can be either 'soft', 'medium' or 'hard'
silent!colorscheme gruvbox
set background=dark  " Specify either "dark" or "light"
" Set custom background color only after `syntax on` and `background=`
highlight LineNr guibg=None guifg=#505050
highlight Normal ctermbg=black

" Make UltiSnip play nicely with completion
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

" Start fzf in a vim window
let g:fzf_layout = { 'down': '~50%' }

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

set signcolumn=no  " Disable the sign column and instead color the line numbers
let g:signify_sign_show_count=0
let g:signify_number_highlight=1

highlight LspDiagnosticsLineNrError guibg=#51202A guifg=#FF0000 gui=bold
highlight LspDiagnosticsLineNrWarning guibg=#51412A guifg=#FFA500 gui=bold
highlight LspDiagnosticsLineNrInformation guibg=#1E535D guifg=#00FFFF gui=bold
highlight LspDiagnosticsLineNrHint guibg=#1E205D guifg=#0000FF gui=bold

highlight SignifySignAdd ctermfg=112 guifg=#009929 guibg=None  " green
highlight SignifySignDelete ctermfg=red guifg=#ff0000 guibg=None
highlight SignifySignChange ctermfg=214 guifg=#fcba03 guibg=None  " orange

sign define DiagnosticSignError text= texthl=LspDiagnosticsSignError linehl= numhl=LspDiagnosticsLineNrError
sign define DiagnosticSignWarn text= texthl=LspDiagnosticsSignWarning linehl= numhl=LspDiagnosticsLineNrWarning
sign define DiagnosticSignInfo text= texthl=LspDiagnosticsSignInformation linehl= numhl=LspDiagnosticsLineNrInformation
sign define DiagnosticSignHint text= texthl=LspDiagnosticsSignHint linehl= numhl=LspDiagnosticsLineNrHint

set scrolloff=6  " Keep a couple of lines below and above the cursor

set tabstop=4     " Number of spaces that a <Tab> in the file counts for.
set shiftwidth=4  " Number of spaces to use for each step of (auto)indent.
set showcmd       " Show (partial) command in status line.

" Configure search
set hlsearch    " Highlight all matches of a previous search
set incsearch   " Show immediately where the so far typed pattern matches
set ignorecase  " Ignore case in search patterns
set smartcase   " Override the 'ignorecase' option if the search pattern contains uppercase

" set diffopt+=iwhite  " Ignore white space

set whichwrap+=<,>,[,]  " Remove line barrier of left and right arrow keys
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

set hidden  " Hide buffers instead of unloading them

" Spell checking
set spell
set spelllang=en_us,de_de

" Search for selection in visual mode via `//`
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Comment code using commentary.vim (C-_ is Ctrl+/)
noremap <C-_> <cmd>Commentary<CR>
vnoremap <C-_> :'<,'>Commentary<CR>
inoremap <C-_> <cmd>Commentary<CR>

" Glance at diffs with signify
nnoremap gp <cmd>SignifyHunkDiff<CR>
nnoremap gu <cmd>SignifyHunkUndo<CR>

" Move cursor by display line not actual line
noremap <Up> gk
vnoremap <Up> gk
inoremap <Up> <C-o>gk
noremap <Down> gj
vnoremap <Down> gj
inoremap <Down> <C-o>gj

" Remaps inspired from GUI apps
noremap <c-o> <cmd>Files<CR>
noremap <c-p> <cmd>Commands<CR>
noremap <c-h> <cmd>Commits<CR>
noremap <c-f> <cmd>Rg<CR>
inoremap <C-s> <cmd>w<CR>
noremap <C-s> <cmd>w<CR>
noremap <C-q> <cmd>q<CR>
nnoremap <C-x> <cmd>bd<CR>
" Switch buffers in various ways
nnoremap <Tab> <cmd>bnext<CR>
nnoremap <S-Tab> <cmd>bprev<CR>
nnoremap ]b <cmd>bnext<CR>
nnoremap [b <cmd>bprev<CR>
nnoremap ]B <cmd>blast<CR>
nnoremap [B <cmd>bfirst<CR>
nnoremap <Leader>b :ls<CR>:b<Space>
nnoremap <Leader># <cmd>b#<CR>
nnoremap <Leader><Leader> <cmd>b#<CR>

nnoremap <Leader>h <cmd>BCommits<CR>
lua << EOF
local nvim_lsp = require('lspconfig')

-- Map keys after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('i', '<C-]>', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', '<C-]>', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)

  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'clangd', 'rust_analyzer', 'pyright' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  },
}

require'nvim-treesitter.configs'.setup {
  ensure_installed = { 'python', 'c', 'cpp', 'rust', 'julia' },  -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = {},  -- list of parsers to ignore installing
  highlight = {
    enable = true,  -- false will disable the whole extension
    disable = { 'python' },  -- use `Semshi` in favor of treesitter for python
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
EOF
