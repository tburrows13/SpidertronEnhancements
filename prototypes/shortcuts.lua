local recall_shortcut = {
  type = "shortcut",
  name = "spidertron-enhancements-recall-shortcut",
  action = "lua",
  associated_control_input = "spidertron-enhancements-recall-shortcut",
  toggleable = true,
  order = "a",
  icon =
  {
    filename = "__SpidertronEnhancements__/graphics/follow-shortcut.png",
    size = 32,
    flags = {"gui-icon"}
  },
  small_icon = {
    filename = "__SpidertronEnhancements__/graphics/follow-shortcut-24.png",
    size = 24,
    flags = {"gui-icon"}
  },
  disabled_icon = {
    filename = "__SpidertronEnhancements__/graphics/follow-shortcut-white.png",
    size = 32,
    flags = {"gui-icon"}
  },
  disabled_small_icon =
  {
    filename = "__SpidertronEnhancements__/graphics/follow-shortcut-white-24.png",
    size = 24,
    flags = {"gui-icon"}
  }
}
local recall_input = {
	type = "custom-input",
	name = "spidertron-enhancements-recall-shortcut",
	key_sequence = "ALT + C",
  consuming = "none",
  order = "a"
}

data:extend{recall_shortcut, recall_input}