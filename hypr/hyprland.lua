-- Hyprland Lua config. See https://wiki.hypr.land/configuring/
-- Settings are split into conf/*.lua; order matters for anything that depends on earlier settings.

require("conf.env")
require("conf.monitors")
require("conf.aesthetics")
require("conf.layout")
require("conf.input")
require("conf.windowrules")
require("conf.calendar")
require("conf.keybinds")
require("conf.autostart")

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/configuring/core/advanced-configuration/permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")
