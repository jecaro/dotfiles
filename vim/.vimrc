" Pugins setup
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

" A good color scheme
colorscheme gruvbox
set background=dark

" Show line numbers
set nu
set colorcolumn=81

" Airline configuration
set laststatus=2
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1

" To be able to switch buffer without saving
set hidden

" Add mouse support in console mode
set mouse=a

" Set leader key as space
let mapleader=" "

" 4 spaces is good
set tabstop=4
" I use spaces for indenting my code
set expandtab
" One tab makes 4 spaces
set shiftwidth=4

" Menu for completion
set wildchar=<Tab> wildmenu wildmode=full
" F10 open the buffer menu
set wildcharm=<C-Z>
nnoremap <F10> :b <C-Z>

" tmux navigator
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <c-left>  :TmuxNavigateLeft<cr>
nnoremap <silent> <c-down>  :TmuxNavigateDown<cr>
nnoremap <silent> <c-up>    :TmuxNavigateUp<cr>
nnoremap <silent> <c-right> :TmuxNavigateRight<cr>
"nnoremap <silent> {Previous-Mapping} :TmuxNavigatePrevious<cr>

" To close a buffer without changin the layout. Usefull when NERDTree is
" opened
map <leader>q :bp<bar>sp<bar>bn<bar>bd<CR>

" For haskell-vim
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

" F5 delete all the trailing whitespaces
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

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
let g:ale_fixers = { 'haskell': ['hlint'] }
