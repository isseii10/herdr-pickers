# herdr-pickers

Two fzf pickers for [herdr](https://herdr.dev), opened as popups:

- **workspace picker**: lists the existing workspaces and your [zoxide](https://github.com/ajeetdsouza/zoxide) directories.
  - Pick a workspace to focus it.
  - Pick a directory to focus the workspace with the same name (the directory's basename). If there is none, the picker creates one. A linked git worktree opens under its main repository's workspace (`herdr worktree open`).
- **agent picker**: lists the running agents with their status, title, workspace and session name. A live preview of the selected agent's recent output is shown below the list. Press enter to focus that agent.

Both pickers start in a vim-like "normal mode":

| key | action |
| --- | --- |
| `j` / `k` | move down / up |
| `g` / `G` | first / last |
| `/` | show the input and fuzzy search (then `j`/`k`/`q` are typed as text) |
| `esc` | hide the input (in normal mode: quit) |
| `enter` | select |
| `q` | quit |

Search results are ranked: the best match comes first, and equal matches keep the list order. The workspace picker scores entries as paths, so it prefers matches right after a `/` and in the directory's own name (`mwa` finds `my-web-app`, `api` finds `~/src/api` before `~/src/api/internal`). Icons and the "current" marker are not searched.

## Requirements

- herdr **0.9.5** or later
- [fzf](https://github.com/junegunn/fzf) **0.59.0** or later (uses `--no-input`, `show-input` / `hide-input` and `$FZF_INPUT_STATE`)
- [jq](https://jqlang.org) (1.6 or later)
- [zoxide](https://github.com/ajeetdsouza/zoxide), for the workspace picker
- bash, and git (optional, used to detect worktrees)
- A [Nerd Font](https://www.nerdfonts.com), for the icons
- macOS or Linux

## Install

```sh
herdr plugin install isseii10/herdr-pickers
```

To try a local checkout instead:

```sh
herdr plugin link /path/to/herdr-pickers
```

## Key bindings

The plugin does not bind any keys itself. Add these to your herdr `config.toml`, then reload the config (`herdr server reload-config`):

```toml
# prefix+s: switch to / create a workspace (existing workspaces + zoxide dirs)
[[keys.command]]
key = "prefix+s"
type = "plugin_action"
command = "isseii10.herdr-pickers.workspace"
description = "workspace picker"

# prefix+a: jump to a running agent (with output preview)
[[keys.command]]
key = "prefix+a"
type = "plugin_action"
command = "isseii10.herdr-pickers.agent"
description = "agent picker"
```

You can also run them from the CLI:

```sh
herdr plugin action invoke workspace --plugin isseii10.herdr-pickers
herdr plugin action invoke agent --plugin isseii10.herdr-pickers
```

## Configuration

Settings are shell variables in `config.env`, in the plugin's config directory:

```sh
cp config.env.example "$(herdr plugin config-dir isseii10.herdr-pickers)/config.env"
```

| variable | default | |
| --- | --- | --- |
| `HERDR_PICKERS_PATH` | `$HOME/.nix-profile/bin:/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin` | Directories prepended to `PATH`. herdr runs plugins with the server's environment, which may not include the directories where fzf / jq / zoxide are installed. |
| `HERDR_PICKERS_COLOR_BLUE` | terminal blue | workspace icon and workspace column |
| `HERDR_PICKERS_COLOR_GREEN` | terminal green | "current" marker, done agents |
| `HERDR_PICKERS_COLOR_YELLOW` | terminal yellow | directory icon, working agents |
| `HERDR_PICKERS_COLOR_RED` | terminal bright red | blocked agents |
| `HERDR_PICKERS_COLOR_GRAY` | terminal bright black | dim text, idle agents |
| `HERDR_PICKERS_WORKSPACE_WIDTH` / `_HEIGHT` | `60%` / `60%` | workspace popup size (`"80%"` or a number of cells) |
| `HERDR_PICKERS_AGENT_WIDTH` / `_HEIGHT` | `80%` / `80%` | agent popup size |
| `HERDR_PICKERS_AGENT_TITLE_MAX` | `50` | longer agent titles are cut with `…` |
| `HERDR_PICKERS_AGENT_PREVIEW_LINES` | `200` | lines of agent output in the preview |

By default the pickers use the terminal's own ANSI colors, so they follow your terminal's color scheme (this matches herdr when its theme is `terminal`). Set a color variable to `#rrggbb` to use that exact color instead. `config.env.example` lists herdr's `one-dark` colors as an example. A value set in `config.env` overrides the same variable from the environment.

## License

MIT
