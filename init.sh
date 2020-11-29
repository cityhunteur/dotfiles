# Installs brew, tools, applications, and copies dot files to their usual path.

set -eEuo pipefail

ROOT="$(cd "$(dirname "$0")/.." &>/dev/null; pwd -P)"

log() { echo "$1" >&2; }

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew cask install google-chrome firefox tidal
brew cask install alacritty iterm2 tmux hyper
brew install coreutils direnv autoenv autojump bat rg ag fzf nmap
brew install git gh
brew cask install sublime-text sublime-merge visual-studio-code
brew cask install charles postico postman tableplus
brew install docker-machine kind helm skaffold kubectx
brew install go python3 node npm openjdk

log "Successfully installed."



