-- See https://wiki.hypr.land/configuring/core/environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Monitor runs at scale 1, so Qt apps (Dolphin) scale themselves to the old 1.5x size
hl.env("QT_SCALE_FACTOR", "1.5")
