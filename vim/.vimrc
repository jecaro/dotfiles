" Sous windows pour trouver -> TODO voir si c'est nécessaire de la garder
if has('win32')
    set runtimepath+=~/.vim
endif

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'morhetz/gruvbox'
Plug 'w0rp/ale'
Plug 'neovimhaskell/haskell-vim'
Plug 'ndmitchell/ghcid', { 'rtp': 'plugins/nvim' }
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mhinz/vim-grepper'
Plug 'christoomey/vim-tmux-navigator'
call plug#end()

" Pour windows
if has('win32')
    " Pour que fugitive fonctionne
    let $PATH .= ';C:\Program Files\Git\bin'

    " Copie directement vers le clipboard de windows
    set clipboard=unnamed

    " On vire tous les widgets
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar

    " Encoding et police pour windows
    set enc=utf-8
    set fileencoding=utf-8
    set fileencodings=ucs-bom,utf8,latin
    set guifont=Consolas:h11
endif

" Chargement des options par default
if !has('nvim')
    source $VIMRUNTIME/vimrc_example.vim
endif

" Un background sombre
colorscheme gruvbox
set background=dark

" Show line number
set nu
set colorcolumn=80

" Airline configuration
set laststatus=2
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1

" Pour pouvoir switcher de buffer sans sauvegarder
set hidden

" Support de la souris en console
set mouse=a
if !has('nvim')
    set ttymouse=xterm2
endif

" Set leader key as space
let mapleader=" "

" 4 espaces pour la tabulation
set tabstop=4
" On utilise des espaces à la place des tabulation
set expandtab
" Un seul tab pour l'autoindent
set shiftwidth=4

" Menu pour la completion
set wildchar=<Tab> wildmenu wildmode=full
" F10 ouvre le menu de buffer
set wildcharm=<C-Z>
nnoremap <F10> :b <C-Z>

" tmux navigator
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <c-left>  :TmuxNavigateLeft<cr>
nnoremap <silent> <c-down>  :TmuxNavigateDown<cr>
nnoremap <silent> <c-up>    :TmuxNavigateUp<cr>
nnoremap <silent> <c-right> :TmuxNavigateRight<cr>
"nnoremap <silent> {Previous-Mapping} :TmuxNavigatePrevious<cr>

" Pour fermer un buffer sans changer le layout de fenetre
map <leader>q :bp<bar>sp<bar>bn<bar>bd<CR>

" Pour haskell-vim
syntax on
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

" Pour fast-tags
augroup tags
au BufWritePost *.hs            silent !init-tags %
au BufWritePost *.hsc           silent !init-tags %
augroup END

" Pour Grepper
nnoremap <leader>ga :Grepper<cr>
nnoremap <leader>gb :Grepper -buffer<cr>

" Pour ALE, on ne garde que hlint
let g:ale_linters = { 'haskell': ['hlint'] }
let g:ale_fixers = { 'haskell': ['hlint'] }
