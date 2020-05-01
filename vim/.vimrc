" Plugins setup
call plug#begin('~/.vim/plugged')
Plug 'airblade/vim-gitgutter'
Plug 'andys8/vim-elm-syntax'
Plug 'christoomey/vim-tmux-navigator'
Plug 'mhinz/vim-grepper'
Plug 'morhetz/gruvbox'
Plug 'ndmitchell/ghcid', { 'rtp': 'plugins/nvim' }
Plug 'neovimhaskell/haskell-vim'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'w0rp/ale'
call plug#end()

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

" To close a buffer without changin the layout. Usefull when NERDTree is
" opened
map <leader>q :bp<bar>sp<bar>bn<bar>bd<CR>
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
" Keys from NERDTree clashes with tmux-navigator so turn them off
let g:NERDTreeMapJumpPrevSibling=""
let g:NERDTreeMapJumpNextSibling=""
map <leader>n :NERDTreeToggle<cr>

" For haskell-vim
syntax on
filetype plugin indent on
let g:haskell_indent_in = 0

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
let g:ale_linters = { 'haskell': ['hlint', 'ghcide'] }
let g:ale_fixers = { 'haskell': ['hlint'] }
