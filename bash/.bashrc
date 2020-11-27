#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

# Setup editor
if ! type nvim > /dev/null 2>&1; then
    export EDITOR=vim
else
    export EDITOR=nvim
fi

# For resize to work propertly
shopt -s checkwinsize

# Better git prompt
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
	source /usr/share/git/completion/git-prompt.sh
fi

if [ "$(type -t __git_ps1)" = 'function' ]; then
	PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
else
	PS1='[\u@\h \W]\$ '
fi

# Git completion
if [ -f /usr/share/git/completion/git-completion.bash ]; then
	source /usr/share/git/completion/git-completion.bash
fi

# FZF completion
if [ -f /usr/share/fzf/key-bindings.bash ]; then
    source /usr/share/fzf/key-bindings.bash
fi
if [ -f /usr/share/fzf/completion.bash ]; then
    source /usr/share/fzf/completion.bash
fi

# My own scripts
export PATH=$PATH:~/bin
# For stack
export PATH=$PATH:~/.local/bin
# On raspberry pi
export PATH=$PATH:/opt/vc/bin
# For node
PATH="$HOME/.node_modules/bin:$PATH"
export npm_config_prefix=~/.node_modules
