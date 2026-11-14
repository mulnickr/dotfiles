hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    kb_options = "",
    kb_rules = "",

    follow_mouse = 1,

    sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

    touchpad = {
      natural_scroll = true,
      scroll_factor = 0.3,
      -- Bottom-edge click zones: left + right only. Enabling middle button
      -- emulation makes libinput drop the middle soft-button area.
      clickfinger_behavior = false,
      middle_button_emulation = true,
    },
  },
})

hl.gesture({
  fingers = 4,
  direction = "horizontal",
  action = "workspace",
})

-- Example per-device config
-- See https://wiki.hypr.land/configuring/core/devices/ for more
hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})
