# VHS tape for the README screenshots. Run it through demo/screenshots, which
# sets up demo mode and a throwaway herdr session and cleans up afterwards.

Output demo/.screenshots.gif

Set Shell "bash"
Set FontFamily "UDEV Gothic NF"
Set FontSize 15
Set Width 1500
Set Height 850
Set Padding 16
Set TypingSpeed 5ms
# Moonfly, converted from Ghostty's theme file
Set Theme { "name": "Moonfly", "black": "#323437", "red": "#ff5454", "green": "#8cc85f", "yellow": "#e3c78a", "blue": "#80a0ff", "magenta": "#cf87e8", "cyan": "#79dac8", "white": "#c6c6c6", "brightBlack": "#949494", "brightRed": "#ff5189", "brightGreen": "#36c692", "brightYellow": "#c6c684", "brightBlue": "#74b2ff", "brightMagenta": "#ae81ff", "brightCyan": "#85dc85", "brightWhite": "#e4e4e4", "background": "#080808", "foreground": "#bdbdbd", "cursor": "#9e9e9e", "selection": "#b2ceee" }

Hide
Type `cd "$DEMO_DIR/my-web-app" && herdr --session herdr-vipicker-demo` Enter
Sleep 5s
Type `bash "$DEMO_ROOT/demo/session-setup" && clear` Enter
Sleep 3s

# 1. workspace picker as it opens
Type "clear && herdr plugin action invoke workspace --plugin isseii10.herdr-vipicker >/dev/null" Enter
Sleep 3s
Show
Screenshot docs/images/workspace-picker.png
Sleep 2s

# 2. searching: workspaces stay above directories
Type "/api"
Sleep 1500ms
Screenshot docs/images/workspace-search.png
Sleep 2s
Escape
Sleep 500ms
Escape
Sleep 1500ms

# 3. agent picker on the blocked agent, with its output in the preview
Type "clear && herdr plugin action invoke agent --plugin isseii10.herdr-vipicker >/dev/null" Enter
Sleep 3s
Type "j"
Sleep 2s
Screenshot docs/images/agent-picker.png
Sleep 2s
Escape
Sleep 1s
