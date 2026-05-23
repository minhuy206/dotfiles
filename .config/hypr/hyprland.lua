-- Entry point. Edit files in modules/ instead.
local cfg = os.getenv("HOME") .. "/.config/hypr"
package.path = cfg .. "/?.lua;" .. cfg .. "/?/init.lua;" .. package.path

require("modules.monitors")
require("modules.env")
require("modules.autostart")
require("modules.input")
require("modules.appearance")
require("modules.animations")
require("modules.binds")
require("modules.windowrules")
