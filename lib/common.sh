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

# Colors as #rrggbb (defaults: herdr's one-dark theme).
: "${HERDR_PICKERS_COLOR_BLUE:=#61afef}"   # workspace icon / workspace column
: "${HERDR_PICKERS_COLOR_GREEN:=#98c379}"  # current marker / done
: "${HERDR_PICKERS_COLOR_YELLOW:=#e5c07b}" # directory icon / working
: "${HERDR_PICKERS_COLOR_RED:=#e06c75}"    # blocked
: "${HERDR_PICKERS_COLOR_GRAY:=#5c6370}"   # dim text / idle

hex_to_ansi() { # #rrggbb -> 24-bit SGR foreground escape
  local h="${1#\#}"
  if [[ ! "$h" =~ ^[0-9a-fA-F]{6}$ ]]; then
    return 0 # invalid -> no color
  fi
  printf '\e[38;2;%d;%d;%dm' "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}
blue="$(hex_to_ansi "$HERDR_PICKERS_COLOR_BLUE")"
green="$(hex_to_ansi "$HERDR_PICKERS_COLOR_GREEN")"
yellow="$(hex_to_ansi "$HERDR_PICKERS_COLOR_YELLOW")"
red="$(hex_to_ansi "$HERDR_PICKERS_COLOR_RED")"
gray="$(hex_to_ansi "$HERDR_PICKERS_COLOR_GRAY")"
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
