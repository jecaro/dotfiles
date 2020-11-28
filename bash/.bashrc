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

# Enable completion
for bcfile in \
    /usr/share/bash-completion/completions/* \
    /etc/bash_completion.d/* \
    ~/.nix-profile/share/bash-completion/completions/* \
    ~/.nix-profile/etc/bash_completion.d/* ; do
  source $bcfile 2> /dev/null
done

# Better git prompt
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

