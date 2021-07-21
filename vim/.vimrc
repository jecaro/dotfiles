" Plugins setup
call plug#begin('~/.vim/plugged')
Plug 'LnL7/vim-nix'
Plug 'airblade/vim-gitgutter'
Plug 'andys8/vim-elm-syntax'
Plug 'christoomey/vim-tmux-navigator'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'justinmk/vim-dirvish'
Plug 'morhetz/gruvbox'
Plug 'ojroques/vim-oscyank'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
if has('nvim')
    Plug 'ndmitchell/ghcid', { 'rtp': 'plugins/nvim' }
endif
if has('nvim-0.5.0')
    Plug 'neovim/nvim-lspconfig'
    Plug 'nvim-lua/completion-nvim'
    Plug 'nvim-lua/lsp-status.nvim'
endif
call plug#end()

" Disable netrw
let g:loaded_netrwPlugin = 1
" For dirvish
" Sort directory first then files
let g:dirvish_mode = ':sort ,^.*[\/],'
" Hide hidden files
autocmd FileType dirvish silent keeppatterns g@\v/\.[^\/]+/?$@d _

" A good color scheme
colorscheme gruvbox
set background=dark

" Show line numbers
set nu
set relativenumber
set colorcolumn=81

" To be able to switch buffer without saving
set hidden

" Add mouse support in console mode
set mouse=a

" 4 spaces is good
set tabstop=4
" I use spaces for indenting my code
set expandtab
" One tab makes 4 spaces
set shiftwidth=4

" Turn on syntax highlight
syntax on
" Activate plugin for specific filetype and indentation
filetype plugin indent on

" Highlights search results as you type vs after you press Enter
set incsearch
" Ignore case when searching
set ignorecase
set smartcase
" Turns search highlighting on
set hlsearch

" Highlight end of line
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" F5 delete all the trailing whitespaces
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

" Highlight yanked text
if has('nvim-0.5.0')
    autocmd TextYankPost * lua vim.highlight.on_yank {
        \higroup="IncSearch", timeout=150, on_visual=true
        \}
endif

" Set leader key as space
let mapleader=" "

" Airline configuration
set laststatus=2
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1

" For vimgutter
let updatetime=100

" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1

" For completion-nvim

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

" For vim-oscyank to copy the plus register in the system clipboard as well
autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '+' | OSCYankReg + | endif

" For FZF to make Ag to search only in file content
" https://github.com/junegunn/fzf.vim/issues/346#issuecomment-655446292
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>,
    \fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

" Function to run fourmolu on the buffer
function! Fourmolu(buffer) abort
    return {
    \   'command': 'fourmolu -o -XTypeApplications -m inplace %t',
    \   'read_temporary_file': 1,
    \}
endfunction

" Function to run ormolu on the buffer
function! Ormolu(buffer) abort
    return {
    \   'command': 'ormolu -o -XTypeApplications -m inplace %t',
    \   'read_temporary_file': 1,
    \}
endfunction

" Add a column by the number to show hints
set signcolumn=yes

" Activate embedded syntax highlight in vimrc file
let g:vimsyn_embed = 'l'
" Activate language servers on neovim
if has('nvim-0.5.0')
lua << EOF
  local nvim_lsp = require('lspconfig')

  local lsp_status = require('lsp-status')
  lsp_status.register_progress()
  lsp_status.config({
      kind_labels = kind_labels,
      indicator_errors = "×",
      indicator_warnings = "!",
      indicator_info = "i",
      indicator_hint = "›",
      -- the default is a wide codepoint which breaks absolute and relative
      -- line counts if placed before airline's Z section
      status_symbol = "",
  })

  local on_attach = function(client)
      -- Activate completion
      require'completion'.on_attach(client)
      lsp_status.on_attach(client)

      -- Mappings
      local opts = { noremap=true }
      vim.api.nvim_buf_set_keymap(0, 'n', '<c-]>',
          '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
      vim.api.nvim_buf_set_keymap(0, 'n', 'K',
          '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
      vim.api.nvim_buf_set_keymap(0, 'n', 'gd',
          '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
      vim.api.nvim_buf_set_keymap(0, 'n', 'gD',
          '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
      vim.api.nvim_buf_set_keymap(0, 'n', 'gr',
          '<cmd>lua vim.lsp.buf.references()<CR>', opts)

      vim.api.nvim_buf_set_keymap(0, 'n', '<leader>ca',
          '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
      vim.api.nvim_buf_set_keymap(0, 'n', '<leader>cr',
          '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ls',
          '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)

      vim.api.nvim_buf_set_keymap(0, 'i', '<C-s>',
          '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

      -- Format on save just for Haskell
      if vim.api.nvim_buf_get_option(0, 'filetype') == 'haskell' then
          vim.api.nvim_command[[
              autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
      end
  end

  nvim_lsp.elmls.setup({ on_attach = on_attach })
  nvim_lsp.hls.setup({
      on_attach = on_attach,
      settings = {
          haskell = {
              hlintOn = true,
              formattingProvider = "fourmolu"
          }
       },
       capabilities = lsp_status.capabilities
  })
  nvim_lsp.ccls.setup({ on_attach = on_attach })

EOF
endif

" Statusline
if has('nvim-0.5.0')
  function! LspStatus() abort
    let status = luaeval('require("lsp-status").status()')
    return trim(status)
  endfunction
  call airline#parts#define_function('lsp_status', 'LspStatus')
  call airline#parts#define_condition('lsp_status',
              \ 'luaeval("#vim.lsp.buf_get_clients() > 0")')
  let g:airline_section_warning = airline#section#create_right(['lsp_status'])
endif
let g:airline#extensions#nvimlsp#enabled = 0

