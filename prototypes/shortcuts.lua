local recall_shortcut = {
  type = "shortcut",
  name = "spidertron-enhancements-recall-shortcut",
  action = "lua",
  associated_control_input = "spidertron-enhancements-recall-shortcut",
  toggleable = true,
  order = "d[spidertron-enhancements]",
  icon = "__SpidertronEnhancements__/graphics/follow-shortcut.png",
  small_icon = "__SpidertronEnhancements__/graphics/follow-shortcut-24.png",
}

local recall_input = {
	type = "custom-input",
	name = "spidertron-enhancements-recall-shortcut",
	key_sequence = "ALT + C",
  consuming = "none",
  order = "a-a"
}

data:extend{recall_shortcut, recall_input}