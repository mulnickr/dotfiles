-- See https://wiki.hypr.land/configuring/core/monitors/
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  -- Whole numbers only: fractional scales make WezTerm crash (Wayland "invalid size"
  -- protocol error). App sizes are bumped 1.5x instead; see README "Display scale".
  scale = "1",
})
