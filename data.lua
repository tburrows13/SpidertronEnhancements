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

data:extend{direct_control, spidertron_pipette, open_inventory}