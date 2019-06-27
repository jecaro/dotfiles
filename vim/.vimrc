" Sous windows pour trouver -> TODO voir si c'est nécessaire de la garder
if has('win32')
	set runtimepath+=~/.vim
endif

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'vim-airline/vim-airline'
Plug 'morhetz/gruvbox'
Plug 'ap/vim-buftabline'
Plug 'w0rp/ale'
Plug 'neovimhaskell/haskell-vim'
Plug 'ndmitchell/ghcid', { 'rtp': 'plugins/nvim' }
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

" Pour maintenir l'affichage de la barre
set laststatus=2

" Pour pouvoir switcher de buffer sans sauvegarder
set hidden

" Support de la souris en console
set mouse=a
if !has('nvim')
	set ttymouse=xterm2
endif

" 4 espaces pour la tabulation
set tabstop=4
" Un seul tab pour l'autoindent
set shiftwidth=4

" Menu pour la completion
set wildchar=<Tab> wildmenu wildmode=full
" F10 ouvre le menu de buffer
set wildcharm=<C-Z>
nnoremap <F10> :b <C-Z>

" Pour fermer un buffer sans changer le layout de fenetre
map <leader>q :bp<bar>sp<bar>bn<bar>bd<CR>

" Pour haskell-vim
syntax on
filetype plugin indent on

" Pour fast-tags
augroup tags
au BufWritePost *.hs            silent !init-tags %
au BufWritePost *.hsc           silent !init-tags %
augroup END
