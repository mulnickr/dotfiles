-- See https://wiki.hypr.land/configuring/core/binds/

-- Programs
-- Separate process per window, so a crash only closes that window
local terminal = "wezterm start --always-new-process"
local fileManager = "dolphin"
local menu = "rofi -show drun"

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(
  mainMod .. " + M",
  hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))

hl.bind(mainMod .. " + V", function()
  local win = hl.get_active_window()
  if not win then
    return
  end

  if win.floating then
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.layout("splitratio 0"))
  else
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.center())
    hl.dispatch(hl.dsp.window.resize({ exact = true, x = 800, y = 600 }))
  end
end)
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("firefox -private-window"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only
hl.bind(mainMod .. " + O", hl.dsp.layout("movetoroot active"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + I", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + D", toggle_calendar) -- Google Calendar (see conf/calendar.lua)

-- Directions: vim keys (same as Neovim and WezTerm panes) and arrow keys both work
local directions = {
  { keys = { "h", "left" },  dir = "left",  dx = -1, dy = 0 },
  { keys = { "j", "down" },  dir = "down",  dx = 0,  dy = 1 },
  { keys = { "k", "up" },    dir = "up",    dx = 0,  dy = -1 },
  { keys = { "l", "right" }, dir = "right", dx = 1,  dy = 0 },
}

for _, d in ipairs(directions) do
  for _, key in ipairs(d.keys) do
    -- Move focus
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = d.dir }))
    -- Move tiles
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = d.dir }))
  end
end

-- Resize mode: mainMod + ALT + R, then h/j/k/l or arrows (hold to repeat),
-- SHIFT for bigger steps. Escape, Enter or mainMod + ALT + R again to leave.
-- Waybar shows "resize" while it's active.
local resizeStep = 40
hl.bind(mainMod .. " + ALT + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
  for _, d in ipairs(directions) do
    for _, key in ipairs(d.keys) do
      hl.bind(
        key,
        hl.dsp.window.resize({ x = d.dx * resizeStep, y = d.dy * resizeStep, relative = true }),
        { repeating = true }
      )
      hl.bind(
        "SHIFT + " .. key,
        hl.dsp.window.resize({ x = d.dx * resizeStep * 4, y = d.dy * resizeStep * 4, relative = true }),
        { repeating = true }
      )
    end
  end
  hl.bind("escape", hl.dsp.submap("reset"))
  hl.bind("Return", hl.dsp.submap("reset"))
  hl.bind(mainMod .. " + ALT + R", hl.dsp.submap("reset"))
end)

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMicMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

----------------
---- GROUPS ----
----------------
-- A group stacks several windows into one tile with a tab bar.
-- Moving a grouped window to a workspace (mainMod + SHIFT + [0-9]) moves the whole group.

-- Create a group from the active window, or dissolve the group it's in
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
-- Lock/unlock the group (locked groups don't accept new windows)
hl.bind(mainMod .. " + CTRL + G", hl.dsp.group.lock({ action = "toggle" }))
-- Pop the active window out of its group
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.window.move({ out_of_group = true }))

-- Move the active window into the neighboring group in a direction (h/j/k/l or arrows)
for _, d in ipairs(directions) do
  for _, key in ipairs(d.keys) do
    hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.move({ into_group = d.dir }))
  end
end

-- Cycle through the tabs of the active group
hl.bind(mainMod .. " + TAB", hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.group.prev())

-- Reorder the active tab within its group (h/l or left/right)
for _, key in ipairs({ "h", "left" }) do
  hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.group.move_window({ forward = false }))
end
for _, key in ipairs({ "l", "right" }) do
  hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.group.move_window({ forward = true }))
end
