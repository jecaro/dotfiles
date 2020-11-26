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
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
if has('nvim')
    Plug 'ndmitchell/ghcid', { 'rtp': 'plugins/nvim' }
endif
if has('nvim-0.5.0')
    Plug 'neovim/nvim-lspconfig'
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

" To have per project settings
set exrc
set secure

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

" Set leader key as space
let mapleader=" "

" F5 delete all the trailing whitespaces
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

" Airline configuration
set laststatus=2
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1

" For vimgutter
let updatetime=100

" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1

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

" Set completeopt to have a better completion experience
" :help completeopt
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect

" Activate language servers on neovim
if has('nvim-0.5.0')
lua << EOF
  local nvim_lsp = require('lspconfig')

  local on_attach = function(client)
      -- Activate completion
      vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

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
           }
      })
  nvim_lsp.vimls.setup({ on_attach = on_attach })

EOF
endif
