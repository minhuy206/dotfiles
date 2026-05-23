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
		},
	},
})

hl.gesture({
	fingers   = 3,
	direction = "horizontal",
	action    = "workspace",
})

hl.device({
	name        = "epic-mouse-v1",
	sensitivity = -0.5,
})
