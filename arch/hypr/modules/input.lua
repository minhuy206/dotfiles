hl.config({
	input = {
		kb_layout  = "us",
		kb_variant = "",
		kb_model   = "",
		kb_options = "",
		kb_rules   = "",

		repeat_rate  = 25,
		repeat_delay = 300,

		follow_mouse = 1,
		sensitivity  = 0,

		touchpad = {
			natural_scroll = true,
			drag_3fg      = 1,
		},
	},
})

hl.gesture({
	fingers   = 4,
	direction = "horizontal",
	action    = "workspace",
})

hl.gesture({
	fingers   = 4,
	direction = "vertical",
	action    = "special",
})

hl.device({
	name        = "epic-mouse-v1",
	sensitivity = -0.5,
})
