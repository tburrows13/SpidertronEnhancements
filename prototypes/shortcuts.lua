local recall_shortcut = {
  type = "shortcut",
  name = "spidertron-enhancements-recall-shortcut",
  action = "lua",
  associated_control_input = "spidertron-enhancements-recall-shortcut",
  toggleable = true,
  order = "d[spidertron-enhancements]",
  icon = "__SpidertronEnhancements__/graphics/follow-shortcut.png",
  icon_size = 32,
  small_icon = "__SpidertronEnhancements__/graphics/follow-shortcut-24.png",
  small_icon_size = 24,
}

local recall_input = {
	type = "custom-input",
	name = "spidertron-enhancements-recall-shortcut",
	key_sequence = "ALT + S",
  consuming = "none",
  order = "a-a"
}

local open_gui_input = {
  type = "custom-input",
  name = "spidertron-enhancements-open-gui",
  key_sequence = "",
  linked_game_control = "open-gui",
  order = "a",
}

data:extend{recall_shortcut, recall_input, open_gui_input}