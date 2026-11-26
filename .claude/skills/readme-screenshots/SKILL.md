---
name: readme-screenshots
description: Regenerate the README screenshots (docs/images/*.png) from demo mode and check them for leaked personal data. Use when the pickers' look changes, or when asked to retake or update the screenshots.
---

# README screenshots

The screenshots come from **demo mode**, never from the user's real herdr session: a real session shows their directories, workspace names, agent titles and agent output, and the README is public. `demo/screenshots` runs `demo/screenshots.tape` in VHS against a throwaway herdr session (`herdr-pickers-demo`) with made-up data (`demo/herdr`, `demo/bin/zoxide`) and a plain `$ ` shell (`demo/shell`), then deletes the session and restores `config.env`.

## Steps

1. **Link this checkout.** `herdr plugin list` must show `isseii10.herdr-pickers` as `local:<this repo>`. If it is installed from GitHub, run `herdr plugin uninstall isseii10.herdr-pickers && herdr plugin link .`, and tell the user, since their installed version changes.
2. **Update the demo if the UI changed.** If the pickers now show something the tape doesn't reach, or the made-up data no longer fits (new columns, new states), edit `demo/herdr` and `demo/screenshots.tape` first.
3. **Run** `demo/screenshots`. Done when it exits 0 and `docs/images/` has `workspace-picker.png`, `workspace-search.png` and `agent-picker.png`.
4. **Look at every image** with the Read tool. Each one must pass all of these checks:
   - **No real data:** only the made-up names (`my-web-app`, `api-server`, `~/src/...`). The user's workspaces, directories, user name, home path and git branches must not appear, including behind the popup and in the sidebar.
   - **Rendering:** icons are drawn (not □), and Japanese titles keep the columns aligned.
   - **State:** shot 1 is the workspace picker as it opens. Shot 2 shows the query `api` with the search-mode header. Shot 3 has the second agent row selected, with its output in the preview.
5. **Scan the files:** `strings docs/images/*.png | grep -i -E '<user name>|/Users/'` finds nothing.
6. **Check the cleanup:** `herdr session list` has no `herdr-pickers-demo`, and the plugin config dir holds only what it held before.
7. Commit the images on the work branch.

## When a shot is wrong

- **Shot shows a later or earlier state:** VHS captures with a lag. Lengthen the `Sleep` around that `Screenshot` in the tape.
- **Text from the pane shows behind the popup:** the typed command printed output. Redirect it to `/dev/null` in the tape.
- **Empty preview or keys not working:** fzf runs its preview as `$SHELL -c ...`. `demo/shell` must pass arguments through to bash.
- **Popup doesn't open:** `bin/open-picker` also reads `config.env`. `demo/herdr` must pass `plugin ...` through to the real herdr.
- **□ instead of icons, or wide gaps in Japanese:** the browser in VHS didn't find the font. Use a family installed directly under `~/Library/Fonts` that has Nerd Font glyphs and CJK (`UDEV Gothic NF`).
