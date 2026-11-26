# herdr-pickers

A herdr plugin (`isseii10.herdr-pickers`): bash + fzf + jq. Published on GitHub with the `herdr-plugin` topic. herdr.dev/plugins indexes the default branch automatically, so every push to `main` is a release that users see. Work on a branch, push it so CI runs, and merge into `main` only when the user explicitly says to merge. `.claude/settings.json` backs this up: pushing to `main` or `gh pr merge` asks the user first (permission rules plus `.claude/hooks/ask-before-main`).

## How the pieces connect

- A key with `type = "plugin_action"` can only invoke an action, not open a pane. So each action runs `bin/open-picker <name>`, which calls `herdr plugin pane open --placement popup` for the matching `[[panes]]` entry.
- Popup panes get no `HERDR_PANE_ID`. Read `HERDR_PLUGIN_CONTEXT_JSON` instead. Plugin commands run with the plugin root as cwd and the herdr server's environment, whose PATH is minimal when the server was started outside a login shell. `lib/common.sh` therefore appends common install dirs as a fallback (the user's PATH still wins). Anyone needing another dir sets `PATH` in `config.env`, which is sourced first; tests use this too.
- User settings are `KEY=value` lines in `$HERDR_PLUGIN_CONFIG_DIR/config.env`, sourced by `lib/common.sh` (pickers) and `bin/open-picker` (popup size). A new setting needs a default in the script, plus an entry in both `config.env.example` and the README table.
- A popup closes when its command exits, so a fatal error goes through `die` (it waits for a key press).
- fzf input lines are tab-separated: hidden ids first, then the searched text, then the "current" marker in its own column. `--nth` counts columns after `--with-nth` is applied, and hidden columns can't be searched. So `--nth=1` searches only the text, and `--tabstop=1` renders the tab before the marker as a single column. fzf placeholders such as `{1}` and the printed selection still use the original columns.
- Search ranks results with `--tiebreak=...,index`, so an empty query shows the input order unchanged. The workspace picker keeps open workspaces above directories while searching, which fzf's own sort can't do: on every query change `lib/rank-groups` ranks each group with `fzf --filter` and reloads the list, and the visible fzf runs with `--no-sort`. Keep the matching options (`match`/`rank` arrays) shared between the two.
- To compare search options, build queries from the list itself (prefixes, `a-b-c` initials, last `-` part of each name) and count how often the intended entry ranks first. That is how `--scheme=path --tiebreak=pathname,index` was chosen for workspaces (93% top-1, against 44% with `--no-sort`).
- Keep fzf ≥ 0.59.0 working (`--no-input`, `show-input`/`hide-input`, `$FZF_INPUT_STATE`). If a change needs a newer fzf, raise `fzf_min` and the README together.

## Testing

- Install the working tree with `herdr plugin link .`. Run actions with `herdr plugin action invoke workspace|agent --plugin isseii10.herdr-pickers`, and read the results with `herdr plugin log list`.
- An invoked popup takes over the user's live herdr screen and has no pane id, so it can't be driven or closed from the CLI. To test end to end, use a temporary `config.env` that puts a stub `fzf` first in `PATH` (`PATH="/path/to/stub:$PATH"`). The stub records its args and stdin, then exits 130 (abort), or prints a harmless line such as the `current` workspace. Delete the temporary `config.env` afterwards.
- To check that fzf accepts the options, have the stub run the real fzf with the same args plus `--filter ''`. Key behaviour (j/k, `/`, esc) can only be checked by a human in a real popup.
- CI (`.github/workflows/ci.yml`) runs `bash -n`, `shellcheck -x` and a manifest check on every push. Run its `run:` commands locally before pushing; when adding a script, add it to them. A variable that `lib/common.sh` sets for the scripts that source it is covered by its file-wide SC2034 disable.
- README screenshots (`docs/images/`) come only from demo mode, never from the user's real session. To retake them, use the `readme-screenshots` skill (`.claude/skills/readme-screenshots/`).
