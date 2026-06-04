-- Entry point. Edit files in modules/ instead.
local cfg = os.getenv("HOME") .. "/.config/hypr"
package.path = cfg .. "/?.lua;" .. cfg .. "/?/init.lua;" .. package.path

local monitors = io.open(cfg .. "/monitors.lua", "r")
if monitors then
	monitors:close()
	require("monitors")
end
require("modules.env")
require("modules.autostart")
require("modules.input")
require("modules.appearance")
require("modules.animations")
require("modules.binds")
require("modules.windowrules")
