# dotfiles
 My configuration files for zsh, tmux, and neovim.

```shell
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh

chmod +x init.sh && ./init.sh

# zsh
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
npm install --global pure-prompt

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# nvim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
```