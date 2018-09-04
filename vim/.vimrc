" Pour windows
if has('win32')
	set runtimepath+=~/.vim
	let $PATH .= ';C:\Program Files\Git\bin'
endif
" Pathogen configuration
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
" Creation de la doc pour les plugins
call pathogen#helptags()


set nocompatible
source $VIMRUNTIME/vimrc_example.vim

" Ces lignes sont dans le fichier par defaut
" source $VIMRUNTIME/mswin.vim
" behave mswin

" Un background sombre
colorscheme torte

" Copie directement vers le clipboard de windows
set clipboard=unnamed

" On vire tous les widgets
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

" Pour maintenir l'affichage de la barre
set laststatus=2

" Pour pouvoir switcher de buffer sans sauvegarder
set hidden

set mouse=a
set ttymouse=xterm2
