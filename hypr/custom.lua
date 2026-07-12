-- hyprland.lua's workspace section only requires("conf.workspace"), which loads
-- the empty conf/workspaces/default.lua stub — it never requires the top-level
-- workspaces.lua that nwg-displays generates (unlike monitors, which requires both).
-- Load it here so workspace-to-monitor assignments actually apply.
require("workspaces")
