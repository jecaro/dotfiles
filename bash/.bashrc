#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

# nvim settup
alias vi=nvim
export EDITOR=nvim

# Prompt completion for git
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
	source /usr/share/git/completion/git-prompt.sh
fi

# Set better prompt with git
if [ "$(type -t __git_ps1)" = 'function' ]; then
	PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
else
	PS1='[\u@\h \W]\$ '
fi

if locale -a | grep ^en_US.UTF-8 ; then
	export LC_ALL=en_US.UTF-8
elif locale -a | grep ^C.UTF-8 ; then
	export LC_ALL=C.UTF-8
fi

# For resize to work propertly
shopt -s checkwinsize

export PATH=$PATH:~/bin
export PATH=$PATH:~/.local/bin
export PATH=$PATH:/opt/vc/bin
