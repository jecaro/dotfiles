[[ -f ~/.bashrc ]] && . ~/.bashrc

# For nixpkgs
if [ -e /home/jc/.nix-profile/etc/profile.d/nix.sh ]; then
    . /home/jc/.nix-profile/etc/profile.d/nix.sh;
fi

