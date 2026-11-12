-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- eDP-1 is left to aquamarine's native lid-close behavior (goes dark with the
-- lid shut) rather than fought — see monitors.lua's lid-workspace-follow.sh,
-- which moves eDP-1's odd workspaces to the S24F350 instead.

-- Custom workspace pair switching (switches both odd and even workspaces together)
for i = 1, 10 do
  o.bind("SUPER + CTRL + code:" .. tostring(i + 9), "Switch to workspace pair", "~/.config/hypr/scripts/workspace-pair.sh " .. tostring(i))
end

-- Free up J/K/L so vim-style H/J/K/L can take over focus/swap/preselect/group,
-- same as the old bindings.conf. Their functionality moves to CTRL+ALT below.
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")
hl.unbind("SUPER + ALT + K")
hl.unbind("SUPER + ALT + L") -- was: Cycle workspace layout back (moved to SUPER+SHIFT+ALT+H)
hl.unbind("SUPER + CTRL + K")

o.bind("CTRL + ALT + J", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + CTRL + K", "Show key bindings", "omarchy-menu-keybindings")

-- Move focus with SUPER + vim keys
o.bind("SUPER + H", "Move window focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Move window focus down", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Move window focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Move window focus right", hl.dsp.focus({ direction = "r" }))

-- Swap windows with SUPER + SHIFT + vim keys
o.bind("SUPER + SHIFT + H", "Swap window left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Swap window right", hl.dsp.window.swap({ direction = "r" }))

-- Move window into group with SUPER + ALT + vim keys
o.bind("SUPER + ALT + H", "Move window to group on left", hl.dsp.window.move({ into_group = "l" }))
o.bind("SUPER + ALT + J", "Move window to group on bottom", hl.dsp.window.move({ into_group = "d" }))
o.bind("SUPER + ALT + K", "Move window to group on top", hl.dsp.window.move({ into_group = "u" }))
o.bind("SUPER + ALT + L", "Move window to group on right", hl.dsp.window.move({ into_group = "r" }))

-- Preselect split direction for next window
o.bind("SUPER + CTRL + ALT + H", "Preselect split left", hl.dsp.layout("preselect l"))
o.bind("SUPER + CTRL + ALT + J", "Preselect split down", hl.dsp.layout("preselect d"))
o.bind("SUPER + CTRL + ALT + K", "Preselect split up", hl.dsp.layout("preselect u"))
o.bind("SUPER + CTRL + ALT + L", "Preselect split right", hl.dsp.layout("preselect r"))

-- Move between windows within a group (same as the default's SUPER+CTRL+LEFT/RIGHT)
hl.unbind("SUPER + CTRL + H")
hl.unbind("SUPER + CTRL + L")
o.bind("SUPER + CTRL + H", "Move grouped window focus left", hl.dsp.group.prev())
o.bind("SUPER + CTRL + L", "Move grouped window focus right", hl.dsp.group.next())

-- Lock/unlock active group
o.bind("SUPER + ALT + B", "Lock/unlock active group", hl.dsp.layout("lockactivegroup toggle"))

-- Workspace configuration switching
o.bind("SUPER + CTRL + SHIFT + ALT + P", "All workspaces to primary monitor", "~/.config/hypr/scripts/workspaces-to-primary.sh")
o.bind("SUPER + CTRL + SHIFT + ALT + S", "Standard workspace configuration", "~/.config/hypr/scripts/workspaces-to-standard.sh")

-- Application bindings not covered by Omarchy defaults
o.bind("SUPER + SHIFT + Z", "Zed", { launch = "zed" })
o.bind("SUPER + SHIFT + T", "Activity", { tui = "btop" })

-- Terminal always attaches to (or creates) the "Root" tmux session, instead
-- of the default's plain shell.
hl.unbind("SUPER + RETURN")
o.bind("SUPER + RETURN", "Terminal", 'uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)" tmux new-session -A -s Root')

-- Terminal in a fresh, randomly-named tmux session (frees up the default Browser binding)
hl.unbind("SUPER + SHIFT + RETURN")
o.bind("SUPER + SHIFT + RETURN", "Terminal (new tmux session)", 'uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)" tmux new')

-- Toggle workspace layout (dwindle <-> scrolling). The default lives on
-- SUPER+L, which the vim-style focus bindings above took over.
o.bind("SUPER + SHIFT + ALT + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
o.bind("SUPER + SHIFT + ALT + H", "Cycle workspace layout back", "omarchy-hyprland-workspace-layout-toggle back")

-- Screenshot to file + clipboard (frees up the default Google Maps binding)
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Screenshot to file + clipboard", "omarchy-capture-screenshot smart")

-- Media play/pause
o.bind("SUPER + grave", "Play/Pause media", "omarchy-swayosd-client --playerctl play-pause")

-- Focus popped-out window
o.bind("SUPER + ALT + O", "Focus pop window", "hyprctl dispatch focuswindow floating")

-- Numpad workspace switching (mirrors SUPER + 1-0)
local numpad_workspace_keys = { "KP_End", "KP_Down", "KP_Next", "KP_Left", "KP_Begin", "KP_Right", "KP_Home", "KP_Up", "KP_Prior", "KP_Insert" }
for i, key in ipairs(numpad_workspace_keys) do
  o.bind("SUPER + " .. key, "Switch to workspace " .. i .. " (numpad)", hl.dsp.focus({ workspace = tostring(i) }))
  o.bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. i .. " (numpad)", hl.dsp.window.move({ workspace = tostring(i) }))
end

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Dictation keys from before Alt + Space and Right Alt became the defaults.
-- Remove these lines to give the keys back to applications.
if o.dictation_installed and o.dictation_installed() then
  o.bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")
  o.bind_hold("F9", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop")
end
