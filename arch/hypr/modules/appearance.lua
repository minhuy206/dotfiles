hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 5,

		border_size = 1,

		col = {
			active_border = { colors = { "rgba(b5b5b5ee)"}},
			inactive_border = "rgba(1a1a1aaa)",
		},

		resize_on_border = false,
		allow_tearing = false,
		layout = "master",
	},

	decoration = {
		rounding = 10,
		rounding_power = 8,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = 0xee1a1a1a,
		},

		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = false,
	},

	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},

	scrolling = {
		fullscreen_on_one_column = true,
	},
})
