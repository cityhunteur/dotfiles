# Starship reads the macOS appearance from its managed configuration.
autoload -Uz add-zsh-hook
# Retire the previous edition's selector when reloading an existing shell.
add-zsh-hook -d precmd _glacier_precmd 2>/dev/null || true
unset STARSHIP_CONFIG
