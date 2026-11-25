# herdr-pickers

A herdr plugin (`isseii10.herdr-pickers`): bash + fzf + jq. Published on GitHub with the `herdr-plugin` topic. herdr.dev/plugins indexes the default branch automatically, so every push to `main` is a release that users see.

## How the pieces connect

- A key with `type = "plugin_action"` can only invoke an action, not open a pane. So each action runs `bin/open-picker <name>`, which calls `herdr plugin pane open --placement popup` for the matching `[[panes]]` entry.
- Popup panes get no `HERDR_PANE_ID`. Read `HERDR_PLUGIN_CONTEXT_JSON` instead. Plugin commands run with the plugin root as cwd and the herdr server's environment. That PATH often lacks Homebrew/Nix, which is why `lib/common.sh` prepends `HERDR_PICKERS_PATH`.
- User settings are `KEY=value` lines in `$HERDR_PLUGIN_CONFIG_DIR/config.env`, sourced by `lib/common.sh` (pickers) and `bin/open-picker` (popup size). A new setting needs a default in the script, plus an entry in both `config.env.example` and the README table.
- A popup closes when its command exits, so a fatal error goes through `die` (it waits for a key press).
- Recently-used ordering: herdr has no MRU API, so `hooks/record-focus` (a `pane.focused` event hook, which also fires on workspace switches) appends to `$HERDR_PLUGIN_STATE_DIR/focus.log`, and `recency_json` in `lib/common.sh` ranks ids by log line order. The hook runs on every focus change, so keep it cheap and free of dependencies (it runs with the server's PATH, before `lib/common.sh` fixes PATH). The pickers' input order is the ranking, and fzf runs with `--tiebreak=index` (no `--no-sort`), so the order also breaks ties while searching. The README "Order" section describes it for users: keep the two in sync.
- After changing `[[events]]` in the manifest, re-run `herdr plugin link .` (or update the install). herdr reads hooks only when the plugin is registered.
- Keep fzf ≥ 0.59.0 working (`--no-input`, `show-input`/`hide-input`, `$FZF_INPUT_STATE`). If a change needs a newer fzf, raise `fzf_min` and the README together.

## Testing

- Install the working tree with `herdr plugin link .`. Run actions with `herdr plugin action invoke workspace|agent --plugin isseii10.herdr-pickers`, and read the results with `herdr plugin log list`.
- An invoked popup takes over the user's live herdr screen and has no pane id, so it can't be driven or closed from the CLI. To test end to end, use a temporary `config.env` that puts a stub `fzf` first in `HERDR_PICKERS_PATH`. The stub records its args and stdin, then exits 130 (abort), or prints a harmless line such as the `current` workspace. Delete the temporary `config.env` afterwards.
- To check that fzf accepts the options, have the stub run the real fzf with the same args plus `--filter ''`. Key behaviour (j/k, `/`, esc) can only be checked by a human in a real popup.
- CI (`.github/workflows/ci.yml`) runs `bash -n`, `shellcheck -x` and a manifest check on every push. Run the same check locally with `shellcheck -x bin/* lib/*.sh hooks/*`. A variable that `lib/common.sh` sets for the scripts that source it is covered by its file-wide SC2034 disable.
