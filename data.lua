require "prototypes.spidertron-transitions"
require "prototypes.simulations"
require "prototypes.shortcuts"
require "prototypes.corpse"

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
}

local spidertron_pipette = {
  type = "custom-input",
  name = "spidertron-enhancements-spidertron-pipette",
  key_sequence = "SHIFT + Q",
}

local open_inventory = {
  type = "custom-input",
  name = "spidertron-enhancements-open-vehicle-inventory",
  key_sequence = "SHIFT + E",
}

local use_remote = {
  type = "custom-input",
  name = "spidertron-enhancements-use-alt-spidertron-remote",
  key_sequence = "ALT + mouse-button-1",
}

data:extend{toggle_driving, direct_control, spidertron_pipette, open_inventory, use_remote}