local mainMod   = "SUPER"
local secondMod = "SUPER + SHIFT"

local terminal   = "kitty"
local fileManager = "nemo"
local browser    = "chromium"
local launcher   = "rofi -show drun -show-icons"
local runner     = "rofi -show run"

-- Applications
hl.bind(mainMod   .. " + T",     hl.dsp.exec_cmd(terminal))
hl.bind(mainMod   .. " + F",     hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod   .. " + E",     hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod   .. " + B",     hl.dsp.exec_cmd(browser))
hl.bind(mainMod   .. " + SPACE", hl.dsp.exec_cmd(launcher))
hl.bind(secondMod .. " + SPACE", hl.dsp.exec_cmd(runner))
hl.bind(mainMod   .. " + R",     hl.dsp.exec_cmd(launcher))

-- Window management
hl.bind(mainMod   .. " + Q", hl.dsp.window.close())
hl.bind(mainMod   .. " + P", hl.dsp.window.pseudo())
hl.bind(secondMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(secondMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Exit
local _sh = io.popen("command -v hyprshutdown 2>/dev/null")
local _has_hyprshutdown = _sh and _sh:read("*a"):match("%S")
if _sh then _sh:close() end
hl.bind(
	secondMod .. " + M",
	_has_hyprshutdown and hl.dsp.exec_cmd("hyprshutdown") or hl.dsp.exit()
)

-- Focus (vim-style)
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Move window
hl.bind(secondMod .. " + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(secondMod .. " + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(secondMod .. " + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(secondMod .. " + j", hl.dsp.window.move({ direction = "down" }))

-- Workspaces
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod   .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(secondMod .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mainMod   .. " + S",        hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod   .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

-- Screenshots
hl.bind("Print",                 hl.dsp.exec_cmd("hyprshot -m output --clipboard-only"))
hl.bind(mainMod   .. " + Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind(secondMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/"))
