function darwin-switch
    cd ~/dotfiles-new
    nix build .#darwinConfigurations.m1-mac.system && sudo ./result/sw/bin/darwin-rebuild switch --flake ~/dotfiles-new#m1-mac
    cd -
end
