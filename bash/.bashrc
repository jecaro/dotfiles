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

# Enable bash completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
fi

# Get FZF share path on nixos
if command -v fzf-share >/dev/null; then
    FZF_SHARE=$(fzf-share)
else
    FZF_SHARE=/usr/share/fzf
fi
# FZF completion
if [ -f $FZF_SHARE/key-bindings.bash ]; then
    source $FZF_SHARE/key-bindings.bash
fi
if [ -f $FZF_SHARE/completion.bash ]; then
    source $FZF_SHARE/completion.bash
fi

# Completion for ssh_host.sh
_complete()
{
  if [ "${#COMP_WORDS[@]}" != "2" ]; then
    return
  fi

  HOSTS=$(cat .ssh/config | awk '/^Host / { print $2 }')
  COMPREPLY=($(compgen -W "$HOSTS" "${COMP_WORDS[1]}"))
}

complete -F _complete ssh_host.sh

# Better git prompt
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
    source /usr/share/git/completion/git-prompt.sh
fi
if [ "$(type -t __git_ps1)" = 'function' ]; then
	PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
else
	PS1='[\u@\h \W]\$ '
fi

# My own scripts
export PATH=$PATH:~/bin
# For stack
export PATH=$PATH:~/.local/bin
# On raspberry pi
if [ -d /opt/vc/bin ]; then
    export PATH=$PATH:/opt/vc/bin
fi

