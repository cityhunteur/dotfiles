# Meister / Continuum — Signal 3.0.0: keep the starship palette in step with
# the macOS appearance (which Ghostty's light/dark theme follows).
#
# ~/.config/starship.toml selects palette "glacier_dark". In light mode we
# point STARSHIP_CONFIG at a cached copy that selects "glacier_light". The
# copy is rebuilt whenever starship.toml is newer. The appearance is read at
# most every 5 seconds to keep `defaults` off the per-prompt hot path.

zmodload -F zsh/datetime p:EPOCHSECONDS
autoload -Uz add-zsh-hook

typeset -g _glacier_checked_at=0
typeset -g _glacier_light_config="${XDG_CACHE_HOME:-$HOME/.cache}/starship/glacier-light.toml"

_glacier_precmd() {
	(( EPOCHSECONDS - _glacier_checked_at < 5 )) && return
	_glacier_checked_at=$EPOCHSECONDS

	if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == Dark ]]; then
		unset STARSHIP_CONFIG
		return
	fi

	local src="$HOME/.config/starship.toml"
	if [[ ! -s $_glacier_light_config || $src -nt $_glacier_light_config ]]; then
		mkdir -p "${_glacier_light_config:h}"
		sed 's/^palette = "glacier_dark"$/palette = "glacier_light"/' "$src" >| "$_glacier_light_config"
	fi
	export STARSHIP_CONFIG=$_glacier_light_config
}

add-zsh-hook precmd _glacier_precmd
