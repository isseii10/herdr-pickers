# herdr-pickers

Two small fzf pickers for [herdr](https://herdr.dev): jump to a workspace (or open one from your zoxide directories), and jump to a running agent with a live preview of its output.

- **Nothing to build.** About 200 lines of bash on top of fzf, jq and zoxide. No Go, Rust or Node toolchain, no build step: `herdr plugin install` and it works.
- **Easy to change.** The whole plugin is a few short scripts. Read them in a few minutes and adapt them to your setup.
- **fzf as you know it.** Matching and ranking are fzf's own, tuned so that the entry you mean comes first.
- **Vim-like keys.** The pickers open in a normal mode: move with `j`/`k` (`g`/`G` for first/last), press `/` to search, and `esc` to stop searching. No modifier keys needed.
- **Wide characters line up.** Agent titles in Japanese, Chinese or Korean keep the columns aligned, because widths are counted in display cells.
- **Your colors.** The pickers use the terminal's ANSI colors, so they match the other programs in your herdr panes without any setting.

## The pickers

Both open as herdr popups:

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

## Uninstall

1. Remove the two `[[keys.command]]` entries ([Key bindings](#key-bindings)) from your herdr `config.toml`, then reload the config (`herdr server reload-config`).
2. Uninstall the plugin:

   ```sh
   herdr plugin uninstall isseii10.herdr-pickers
   ```

   If you linked a local checkout, run `herdr plugin unlink isseii10.herdr-pickers` instead.
3. herdr keeps the plugin's config directory. If you created a `config.env`, delete it yourself:

   ```sh
   rm -r "$(herdr plugin config-dir isseii10.herdr-pickers)"
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
| `HERDR_PICKERS_WORKSPACE_WIDTH` / `_HEIGHT` | `60%` / `60%` | workspace popup size (`"80%"` or a number of cells) |
| `HERDR_PICKERS_AGENT_WIDTH` / `_HEIGHT` | `80%` / `80%` | agent popup size |
| `HERDR_PICKERS_AGENT_TITLE_MAX` | `50` | longer agent titles are cut with `…` |
| `HERDR_PICKERS_AGENT_PREVIEW_LINES` | `200` | lines of agent output in the preview |

A value set in `config.env` overrides the same variable from the environment.

The pickers use the terminal's own ANSI colors, so they follow your terminal's color scheme, like the other programs in your herdr panes. To change them, change the terminal's theme.

## License

MIT
