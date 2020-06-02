" Plugins setup
call plug#begin('~/.vim/plugged')
Plug 'airblade/vim-gitgutter'
Plug 'andys8/vim-elm-syntax'
Plug 'christoomey/vim-tmux-navigator'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'justinmk/vim-dirvish'
Plug 'mhinz/vim-grepper'
Plug 'morhetz/gruvbox'
Plug 'ndmitchell/ghcid', { 'rtp': 'plugins/nvim' }
Plug 'neovimhaskell/haskell-vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'w0rp/ale'
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

" Set leader key as space
let mapleader=" "

" Menu for completion
set wildchar=<Tab> wildmenu wildmode=full
" F10 open the buffer menu
set wildcharm=<C-Z>
nnoremap <F10> :b <C-Z>

" F5 delete all the trailing whitespaces
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

" Airline configuration
set laststatus=2
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1

" For vimgutter
let updatetime=100

" For fast-tags
augroup tags
au BufWritePost *.hs            silent !init-tags %
au BufWritePost *.hsc           silent !init-tags %
augroup END

" For Grepper
nnoremap <leader>g :Grepper -tool git<cr>
nnoremap <leader>G :Grepper -tool ag<cr>
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)

" For ALE
let g:ale_linters = { 'haskell': ['hlint'] }
let g:ale_fixers = { 'haskell': ['Fourmolu'], 'elm': ['elm-format'] }
let g:ale_fix_on_save = 1

" Function to run fourmolu on the buffer
function! Fourmolu(buffer) abort
    return {
    \   'command': 'fourmolu -o -XTypeApplications -m inplace %t',
    \   'read_temporary_file': 1,
    \}
endfunction

