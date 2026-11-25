# shellcheck shell=bash
# shellcheck disable=SC2034 # the variables set here are used by the scripts that source this file
# Shared setup for the pickers: config, PATH, dependency checks, colors, fzf keys.

herdr="${HERDR_BIN_PATH:-herdr}"

# --- config -----------------------------------------------------------------
# User settings live in $HERDR_PLUGIN_CONFIG_DIR/config.env (plain shell,
# `KEY=value` lines). Variables already set in the environment win over the
# built-in defaults below, and config.env wins over both.
config_file="${HERDR_PLUGIN_CONFIG_DIR:-\$(herdr plugin config-dir isseii10.herdr-pickers)}/config.env"
if [ -f "$config_file" ]; then
  # shellcheck source=/dev/null
  . "$config_file"
fi

# Directories prepended to PATH. herdr runs plugin commands with the server's
# environment, which often lacks Homebrew / Nix / ~/.local paths.
: "${HERDR_PICKERS_PATH:=$HOME/.nix-profile/bin:/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin}"
export PATH="$HERDR_PICKERS_PATH:$PATH"

# Colors: the terminal's own ANSI colors, so the pickers follow the terminal's
# color scheme like everything else inside a herdr pane.
blue=$'\e[34m'   # workspace icon / workspace column
green=$'\e[32m'  # current marker / done
yellow=$'\e[33m' # directory icon / working
red=$'\e[91m'    # blocked (bright red, to stand out)
gray=$'\e[90m'   # dim text / idle (bright black)
reset=$'\e[0m'

# --- dependency checks --------------------------------------------------------
# A popup closes as soon as its command exits, so errors wait for a key press.
die() {
  printf 'herdr-pickers: %s\n\n(press any key to close)' "$*" >&2
  read -r -n1 -s || true
  exit 1
}

require() { # <command>...
  local c
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || die "'$c' not found in PATH. Install it or set HERDR_PICKERS_PATH in $config_file"
  done
}

fzf_min="0.59.0" # --no-input, show-input/hide-input, $FZF_INPUT_STATE
require_fzf() {
  require fzf
  local v
  v="$(fzf --version | awk '{print $1}')"
  if [ "$(printf '%s\n%s\n' "$fzf_min" "$v" | sort -t. -k1,1n -k2,2n -k3,3n | head -n1)" != "$fzf_min" ]; then
    die "fzf $v is too old (need >= $fzf_min)"
  fi
}

# --- fzf "normal mode" --------------------------------------------------------
# Start with the input hidden and move with j/k; `/` shows the input for fuzzy
# search (j/k/q are then typed as text), esc hides it again (or quits).
normal_key() { # <key> <action in normal mode>
  printf -- "--bind=%s:transform:[ \"\$FZF_INPUT_STATE\" = enabled ] && echo 'put(%s)' || echo '%s'" "$1" "$1" "$2"
}
normal_mode_binds=(
  "$(normal_key j down)"
  "$(normal_key k up)"
  "$(normal_key g first)"
  "$(normal_key G last)"
  "$(normal_key q abort)"
  "$(normal_key / show-input)"
  # clear-query does not work inside transform output, so it runs outside (no-op in normal mode)
  "--bind=esc:clear-query+transform:[ \"\$FZF_INPUT_STATE\" = enabled ] && echo hide-input || echo abort"
)
