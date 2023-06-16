require "prototypes.spidertron-scale"
require "prototypes.spidertron-transitions"
require "prototypes.simulations"
require "prototypes.shortcuts"
require "prototypes.corpse"

local use_remote = {
  type = "custom-input",
  name = "spidertron-enhancements-use-alt-spidertron-remote",
  key_sequence = "ALT + mouse-button-1",
  controller_key_sequence = "controller-lefttrigger + controller-righttrigger + controller-a",
  order = "a-b",
}

local toggle_driving = {
  type = "custom-input",
  name = "spidertron-enhancements-toggle-driving",
  key_sequence = "",
  linked_game_control = "toggle-driving",
}

local direct_control = {
  type = "custom-input",
  name = "spidertron-enhancements-enter-vehicles",
  key_sequence = "U",
  order = "b",
}

local open_inventory = {
  type = "custom-input",
  name = "spidertron-enhancements-open-vehicle-inventory",
  key_sequence = "SHIFT + E",
  order = "c",
}


local spidertron_pipette = {
  type = "custom-input",
  name = "spidertron-enhancements-spidertron-pipette",
  key_sequence = "SHIFT + Q",
  order = "d-a",
}

local spidertron_patrol_pipette = {
  type = "custom-input",
  name = "spidertron-enhancements-spidertron-patrol-pipette",
  key_sequence = "CONTROL + SHIFT + Q",
  order = "d-b",
}

local disconnect_remote = {
  type = "custom-input",
  name = "spidertron-enhancements-disconnect-remote",
  key_sequence = "",
  linked_game_control = "stack-split",  -- SHIFT + mouse-button-2 by default
  consuming = "none",
  order = "ab"
}

data:extend{toggle_driving, direct_control, spidertron_pipette, spidertron_patrol_pipette, open_inventory, use_remote, disconnect_remote}