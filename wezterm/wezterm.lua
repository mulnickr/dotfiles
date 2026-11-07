local wezterm = require("wezterm")

local is_windows = wezterm.target_triple:find("windows") ~= nil

local config = {
  -- Windows only; elsewhere WezTerm uses the login shell
  default_prog = is_windows and { "powershell.exe" } or nil,
  audible_bell = "Disabled",
  check_for_updates = false,
  -- color_scheme = "Builtin Solarized Dark",
  color_scheme = "Ayu Mirage",
  -- color_scheme = "Azu (Gogh)"
  inactive_pane_hsb = {
    hue = 1.0,
    saturation = 1.0,
    brightness = 0.7, -- 1.0
  },
  font_size = 10,
  launch_menu = {},
  disable_default_key_bindings = true,

  -- Window Appearance
  use_fancy_tab_bar = false,
  -- enable_tab_bar = false,
  -- hide_tab_bar_if_only_one_tab = true,
  -- tab_bar_at_bottom = true,
  enable_scroll_bar = false,
  initial_cols = 125,
  initial_rows = 45,
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },


  -- Keybinds
  leader = { key = " ", mods = "CTRL", timeout_milliseconds = 1500 },
  keys = {
    -- Reminder: Sending actions to the terminal if leader key is pressed
    -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
    -- { key = "a", mods = "LEADER|CTRL",  action=wezterm.action{SendString="\x01"}},
    { key = "-",         mods = "LEADER",       action = wezterm.action { SplitVertical = { domain = "CurrentPaneDomain" } } },
    { key = "\\",        mods = "LEADER",       action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
    { key = "LeftArrow", mods = "LEADER",       action = wezterm.action.SplitPane { direction = 'Left', size = { Percent = 50 }, }, },
    { key = "i",         mods = "LEADER",       action = "TogglePaneZoomState" },
    { key = "c",         mods = "LEADER",       action = wezterm.action { SpawnTab = "CurrentPaneDomain" } },
    { key = "s",         mods = "LEADER",       action = wezterm.action.PaneSelect },
    { key = "h",         mods = "LEADER",       action = wezterm.action { ActivatePaneDirection = "Left" } },
    { key = "j",         mods = "LEADER",       action = wezterm.action { ActivatePaneDirection = "Down" } },
    { key = "k",         mods = "LEADER",       action = wezterm.action { ActivatePaneDirection = "Up" } },
    { key = "l",         mods = "LEADER",       action = wezterm.action { ActivatePaneDirection = "Right" } },
    { key = "H",         mods = "LEADER|SHIFT", action = wezterm.action { AdjustPaneSize = { "Left", 15 } } },
    { key = "J",         mods = "LEADER|SHIFT", action = wezterm.action { AdjustPaneSize = { "Down", 10 } } },
    { key = "K",         mods = "LEADER|SHIFT", action = wezterm.action { AdjustPaneSize = { "Up", 10 } } },
    { key = "L",         mods = "LEADER|SHIFT", action = wezterm.action { AdjustPaneSize = { "Right", 15 } } },
    { key = "1",         mods = "LEADER",       action = wezterm.action { ActivateTab = 0 } },
    { key = "2",         mods = "LEADER",       action = wezterm.action { ActivateTab = 1 } },
    { key = "3",         mods = "LEADER",       action = wezterm.action { ActivateTab = 2 } },
    { key = "4",         mods = "LEADER",       action = wezterm.action { ActivateTab = 3 } },
    { key = "5",         mods = "LEADER",       action = wezterm.action { ActivateTab = 4 } },
    { key = "6",         mods = "LEADER",       action = wezterm.action { ActivateTab = 5 } },
    { key = "7",         mods = "LEADER",       action = wezterm.action { ActivateTab = 6 } },
    { key = "8",         mods = "LEADER",       action = wezterm.action { ActivateTab = 7 } },
    { key = "9",         mods = "LEADER",       action = wezterm.action { ActivateTab = 8 } },
    { key = "&",         mods = "LEADER|SHIFT", action = wezterm.action { CloseCurrentTab = { confirm = true } } },
    { key = "x",         mods = "LEADER",       action = wezterm.action { CloseCurrentPane = { confirm = true } } },
    { key = "P",         mods = "LEADER",       action = wezterm.action.ActivateCommandPalette },

    -- Don't really need these...
    { key = "n",         mods = "SHIFT|CTRL",   action = "ToggleFullScreen" },
    { key = "v",         mods = "SHIFT|CTRL",   action = wezterm.action.PasteFrom 'Clipboard' },
    { key = "c",         mods = "SHIFT|CTRL",   action = wezterm.action.CopyTo 'Clipboard' },
    { key = "+",         mods = "SHIFT|CTRL",   action = "IncreaseFontSize" },
    { key = "-",         mods = "SHIFT|CTRL",   action = "DecreaseFontSize" },
    { key = "0",         mods = "SHIFT|CTRL",   action = "ResetFontSize" },
  },
  set_environment_variables = {},
}


-- Window Title
wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  local icon = wezterm.nerdfonts.cod_flame
  local zoomed = ''
  if tab.active_pane.is_zoomed then
    zoomed = '[' .. icon .. '] '
  end

  local index = ''
  if #tabs > 1 then
    index = string.format('[%d/%d] ', tab.tab_index + 1, #tabs)
  end

  return zoomed .. index
end)

function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local title = pane.pane_id .. ': ' .. basename(pane.foreground_process_name)

  local fg = 'gray'
  if tab.is_active then
    fg = 'black'
  end

  return {
    { Background = { Color = '#C9C3B8' } },
    { Foreground = { Color = '#1C1C1C' } },
    { Text = ' ' .. title .. ' ' }
  }
end)

-- Display an indicator when leader key is active
wezterm.on('update-right-status', function(window, pane)
  local left_icon = wezterm.nerdfonts.pl_right_hard_divider
  local leader_icon = wezterm.nerdfonts.cod_flame
  -- wezterm.nerdfonts.magnifier_plus
  local leader_active = wezterm.format({
    { Background = { Color = '#C9C3B8' } },
    { Foreground = { Color = '#1C1C1C' } },
    { Text = ' ' .. leader_icon .. ' ' }
  })

  if window:leader_is_active() then
    window:set_right_status(leader_active)
  else
    window:set_right_status("")
  end
end)

-- Initial common panes and tabs on startup
local mux = wezterm.mux
-- local act = wezterm.action


-- MusicTheory Web App Startup
local web_startup = function(cmd)
  local args = { "powershell.exe" }
  if cmd then
    args = cmd.args
  end

  local backend_dir = "C:/Users/ramis/Desktop/MusicTheoryGo"
  -- local tab, pane, window
  local _, backend, _ = mux.spawn_window {
    workspace = 'backend',
    cwd = backend_dir,
    args = args,
  }

  local frontend_dir = "C:/Users/ramis/Desktop/MusicTheoryFrontend-Mantine/MusicTheoryFrontend"
  local frontend = backend:split {
    workspace = 'frontend',
    direction = 'Right',
    cwd = frontend_dir,
  }

  backend:split {
    direction = 'Bottom',
    size = 0.2,
  }

  frontend:split {
    direction = 'Bottom',
    size = 0.2,
  }

  -- local window = mux:get_window(0)
  -- window.set_title("Development")
  -- window.perform_action(act.ClearScrollback, backend)
  -- window.perform_action(act.ClearScrollback, bterm)
  -- window.perform_action(act.ClearScrollback, frontend)
  -- window.perform_action(act.ClearScrollback, fterm)

  -- frontend.send_text 'nvim\n'
  -- backend.send_text 'nvim\n'

  mux.set_active_workspace 'backend'
end


-- MusicTheoryApi Startup
local api_startup = function(cmd)
  local args = { "powershell.exe" }
  if cmd then
    args = cmd.args
  end

  local api_dir = "C:/Users/ramis/Desktop/music-theory-api"
  -- local tab, pane, window
  local _, api, _ = mux.spawn_window {
    workspace = 'api',
    cwd = api_dir,
    args = args,
  }

  local claude_dir = "C:/Users/ramis/Desktop/music-theory-api"
  api:split {
    workspace = 'claude',
    direction = 'Right',
    cwd = claude_dir,
  }

  api:split {
    direction = 'Bottom',
    size = 0.2,
  }

  mux.set_active_workspace 'api'
end



-- Project layouts use Windows paths, so only open them there
if is_windows then
  wezterm.on('gui-startup', api_startup)
end

return config
