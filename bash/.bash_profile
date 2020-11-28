[[ -f ~/.bashrc ]] && . ~/.bashrc

# For nixpkgs
if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
    . $HOME/.nix-profile/etc/profile.d/nix.sh;
fi

