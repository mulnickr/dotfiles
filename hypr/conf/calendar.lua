-- Google Calendar in a centered floating window.
-- Runs as a separate Firefox instance (profile "gcal") with class "gcal", so the
-- rule below only matches the calendar and not your normal Firefox windows.
-- Waybar's clock calls this with: hyprctl eval 'toggle_calendar()'

local CLASS = "gcal"
local URL   = "https://calendar.google.com"

hl.window_rule({
    name  = "gcal-float",
    match = { class = "^" .. CLASS .. "$" },

    float  = true,
    size   = "monitor_w*0.7 monitor_h*0.75",
    center = true,
})

-- Open the calendar; if it's open elsewhere, bring it here; if it's focused, close it.
function toggle_calendar()
    local win = hl.get_windows({ class = CLASS })[1]

    if not win then
        hl.dispatch(hl.dsp.exec_cmd(
            "firefox --new-instance -P " .. CLASS .. " --name " .. CLASS .. " " .. URL))
        return
    end

    local active = hl.get_active_window()

    if active and active.address == win.address then
        hl.dispatch(hl.dsp.window.close({ window = win }))
    else
        local ws = hl.get_active_workspace()
        if ws then
            hl.dispatch(hl.dsp.window.move({ workspace = ws.id, window = win }))
        end
        hl.dispatch(hl.dsp.focus({ window = win }))
    end
end
