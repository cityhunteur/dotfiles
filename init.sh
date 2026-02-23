#!/usr/bin/env bash
#
# init.sh - Idempotent dotfiles setup
#
# Usage:
#   git clone --depth 1 https://github.com/cityhunteur/dotfiles
#   cd dotfiles
#   ./init.sh

set -eEuo pipefail

# =============================================================================
# Helper Functions
# =============================================================================

log() { echo "==> $1" >&2; }
info() { echo "    $1" >&2; }

# Create symlink safely (backup existing files, skip if already linked)
safe_symlink() {
    local src="$1"
    local dst="$2"

    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"

    # If destination is already a symlink pointing to source, skip
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        info "Already linked: $dst"
        return 0
    fi

    # If destination exists (file or different symlink), backup
    if [[ -e "$dst" || -L "$dst" ]]; then
        local backup="${dst}.backup.$(date +%s)"
        info "Backing up existing: $dst -> $backup"
        mv "$dst" "$backup"
    fi

    ln -sf "$src" "$dst"
    info "Linked: $src -> $dst"
}

# =============================================================================
# Main Setup
# =============================================================================

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

log "Starting dotfiles setup..."

# -----------------------------------------------------------------------------
# Zerobrew (fast Homebrew alternative for formulas)
# -----------------------------------------------------------------------------
if ! command -v zb &>/dev/null; then
    log "Installing Zerobrew..."
    curl -sSL https://raw.githubusercontent.com/lucasgelfond/zerobrew/main/install.sh | bash
else
    info "Zerobrew already installed"
fi

# -----------------------------------------------------------------------------
# Homebrew (needed for casks and taps)
# -----------------------------------------------------------------------------
if ! command -v brew &>/dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    info "Homebrew already installed"
fi

# -----------------------------------------------------------------------------
# Taps (via brew)
# -----------------------------------------------------------------------------
log "Adding taps..."
brew tap 1password/tap 2>/dev/null || true
brew tap derailed/k9s 2>/dev/null || true
brew tap hashicorp/tap 2>/dev/null || true
brew tap oven-sh/bun 2>/dev/null || true

# -----------------------------------------------------------------------------
# CLI Tools (via zerobrew - 2-7x faster)
# -----------------------------------------------------------------------------
log "Installing CLI tools via Zerobrew..."

FORMULAS=(
    # CLI Tools
    atuin awscli aws-sso-cli bat curl direnv fd fzf gh git git-lfs
    glow gnu-sed gnupg htop jq ripgrep starship tmux tree watch wget yq
    zoxide zsh-autosuggestions zsh-syntax-highlighting
    # Languages
    go golangci-lint rustup-init uv ruff pyenv volta
    # Editor
    helix
    # Kubernetes & Cloud
    kubernetes-cli kubectx kind helm kustomize
    terraform tflint terraform-docs
    # Docker
    docker docker-compose dive
)

# Tapped formulas (need full path)
TAPPED_FORMULAS=(
    "oven-sh/bun/bun"
    "derailed/k9s/k9s"
    "hashicorp/tap/terraform-ls"
)

for formula in "${FORMULAS[@]}"; do
    if ! zb list 2>/dev/null | grep -q "^$formula\$"; then
        zb install "$formula" 2>/dev/null || brew install "$formula" || info "Failed to install: $formula"
    else
        info "Already installed: $formula"
    fi
done

# Tapped formulas via brew (zb doesn't support taps)
for formula in "${TAPPED_FORMULAS[@]}"; do
    if ! brew list "$formula" &>/dev/null; then
        brew install "$formula"
    else
        info "Already installed: $formula"
    fi
done

# -----------------------------------------------------------------------------
# Desktop Applications (casks via brew)
# -----------------------------------------------------------------------------
log "Installing desktop applications..."

CASKS=(
    ghostty zed claude
    google-chrome zen
    1password 1password-cli
    gitkraken karabiner-elements
    raycast slack
    spotify tidal
)

for cask in "${CASKS[@]}"; do
    if ! brew list --cask "$cask" &>/dev/null; then
        brew install --cask "$cask" || info "Failed to install cask: $cask"
    else
        info "Already installed: $cask"
    fi
done

# -----------------------------------------------------------------------------
# Oh My Zsh
# -----------------------------------------------------------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    info "Oh My Zsh already installed"
fi

# Oh My Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    log "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    info "zsh-autosuggestions already installed"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    log "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    info "zsh-syntax-highlighting already installed"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
    log "Installing zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
else
    info "zsh-completions already installed"
fi

# -----------------------------------------------------------------------------
# Tmux Plugin Manager
# -----------------------------------------------------------------------------
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    log "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    info "Tmux Plugin Manager already installed"
fi

# -----------------------------------------------------------------------------
# Coding Agents (via Bun)
# -----------------------------------------------------------------------------
log "Installing coding agents via Bun..."

if command -v bun &>/dev/null; then
    # Claude Code
    if ! command -v claude &>/dev/null; then
        bun install -g @anthropic-ai/claude-code
        info "Installed: claude-code"
    else
        info "claude-code already installed"
    fi

    # Codex
    if ! command -v codex &>/dev/null; then
        bun install -g @openai/codex
        info "Installed: codex"
    else
        info "codex already installed"
    fi

    # Gemini CLI
    if ! command -v gemini &>/dev/null; then
        bun install -g @google/gemini-cli
        info "Installed: gemini-cli"
    else
        info "gemini-cli already installed"
    fi
else
    info "Bun not found, skipping coding agents installation"
fi

# -----------------------------------------------------------------------------
# Symlinks
# -----------------------------------------------------------------------------
log "Creating symlinks..."

# Shell configs
safe_symlink "$REPO_ROOT/.zshrc" "$HOME/.zshrc"
safe_symlink "$REPO_ROOT/.gitconfig" "$HOME/.gitconfig"
safe_symlink "$REPO_ROOT/.fzf.zsh" "$HOME/.fzf.zsh"
safe_symlink "$REPO_ROOT/.tmux.conf" "$HOME/.tmux.conf"

# .config files
safe_symlink "$REPO_ROOT/.config/starship.toml" "$HOME/.config/starship.toml"
safe_symlink "$REPO_ROOT/.config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
safe_symlink "$REPO_ROOT/.config/bat/config" "$HOME/.config/bat/config"
safe_symlink "$REPO_ROOT/.config/helix/config.toml" "$HOME/.config/helix/config.toml"
safe_symlink "$REPO_ROOT/.config/zed/settings.json" "$HOME/.config/zed/settings.json"

# Ghostty (uses Application Support on macOS)
safe_symlink "$REPO_ROOT/.config/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

# Karabiner (entire directory)
if [[ -d "$REPO_ROOT/.config/karabiner" ]]; then
    safe_symlink "$REPO_ROOT/.config/karabiner" "$HOME/.config/karabiner"
fi

# -----------------------------------------------------------------------------
# SSH Setup (optional - requires user interaction)
# -----------------------------------------------------------------------------
log "Setup complete!"
info ""
info "Optional: Run these commands to configure SSH/Git auth:"
info "  gh auth login"
info "  eval \"\$(ssh-agent -s)\""
info "  ssh-add --apple-use-keychain ~/.ssh/id_ed25519"
info ""
info "Then reload your shell:"
info "  source ~/.zshrc"
