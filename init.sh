#!/usr/bin/env bash
#
# init.sh
#
# This script is a helper script to install brew, applications using brew bundle, oh my zsh and tmux plugin manager.
# It also copies dot files and other settings to their usual path.
#
# Instructions:
# $ git clone --depth 1 https://github.com/cityhunteur/dotfiles
# $ cd dotfiles
# $ ./init.sh

set -eEuo pipefail

function log() { echo "$1" >&2; }

log "Starting installations..."

log "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

log "Installing homebrew bundle..."
brew bundle

log "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
git clone https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions"
curl -#fLo- 'https://raw.githubusercontent.com/hyperupcall/autoenv/master/scripts/install.sh' | sh

log "Installing Tmux Plugin Manager..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

log "Configuring shell..."
npm i -g  pure-prompt

log "Configuring ssh..."
gh auth login
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

log "Successfully installed."
