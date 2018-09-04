#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias vi=vim
PS1='[\u@\h \W]\$ '

export LC_ALL=en_US.UTF-8

export EDITOR=vim

shopt -s checkwinsize

# Disable PANGO optimizes firefox
export MOZ_DISABLE_PANGO=1

export PATH=$PATH:~/bin
export PATH=$PATH:~/.local/bin
export PATH=$PATH:/opt/vc/bin
