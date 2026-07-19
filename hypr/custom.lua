-- hyprland.lua's workspace section only requires("conf.workspace"), which loads
-- the empty conf/workspaces/default.lua stub — it never requires the top-level
-- workspaces.lua that nwg-displays generates (unlike monitors, which requires both).
-- Load it here so workspace-to-monitor assignments actually apply.
require("workspaces")

-- Wine/XWayland absolute-pointer fix (2026-07-16).
-- Symptom: in Proton games (SE2, Rocket League) relative aim was flawless but UI
-- hover hit-testing landed in the wrong place. Relative motion and absolute
-- position are separate paths; only the absolute one was broken.
-- XWayland's coordinate space disagreed with Hyprland's about monitor order, and
-- no primary output was set, so Wine had nothing authoritative to resolve
-- absolute coords against. Two halves to the fix:
--   1. Monitor layout origin at 0,0 with DP-1 leftmost -- see monitors.lua.
--   2. An explicit XWayland primary output -- below.
-- Verify with: DISPLAY=:0 xrandr --query | grep -E ' connected|Screen 0'
-- The positions there should match `hyprctl monitors`, and DP-1 must say "primary".

hl.config({
    cursor = {
        -- On NVIDIA the default "auto" (2) does not reliably opt out of the
        -- hardware cursor. Forcing both fixed part of the cursor misbehaviour.
        no_hardware_cursors = true,
        use_cpu_buffer = true,
    },
})

hl.on("hyprland.start", function()
    -- XWayland starts lazily, so xrandr can't reach it at hyprland.start.
    -- Retry until the display answers, then give up rather than loop forever.
    hl.exec_cmd("sh -c 'for i in $(seq 30); do DISPLAY=:0 xrandr --output DP-1 --primary >/dev/null 2>&1 && exit 0; sleep 1; done'")
end)
