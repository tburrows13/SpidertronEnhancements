require "prototypes.spidertron-transitions"
require "prototypes.simulations"
require "prototypes.shortcuts"
require "prototypes.corpse"

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

local prototype = data.raw["spidertron-remote"]["spidertron-remote"]
prototype.localised_description = {"item-description.spidertron-enhancements-spidertron-remote-append", {"item-description.spidertron-remote"}}

data:extend{direct_control, spidertron_pipette, open_inventory, use_remote}