SPIDERTRON_NAME = "spidertron"
SPIDERTRON_NAME_CAPITALISED = "Spidertron"
if mods["maraxsis"] or mods["lex-aircraft"] then
  SPIDERTRON_NAME = "vehicle"
  SPIDERTRON_NAME_CAPITALISED = "Vehicle"
end

require "prototypes.spidertron-scale"
require "prototypes.spidertron-transitions"
require "prototypes.tips-and-tricks"
require "prototypes.custom-input"
require "prototypes.corpse"

data:extend{{
  type = "custom-event",
  name = "on_spidertron_replaced",
}}

local use_remote = {
  type = "custom-input",
  name = "spidertron-enhancements-use-alt-spidertron-remote",
  key_sequence = "CONTROL + mouse-button-2",
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
  key_sequence = "SHIFT + RETURN",
  order = "b",
}

local open_inventory = {
  type = "custom-input",
  name = "spidertron-enhancements-open-vehicle-inventory",
  key_sequence = "SHIFT + E",
  order = "c-a",
}

local open_in_map = {
  type = "custom-input",
  name = "spidertron-enhancements-open-in-map",
  key_sequence = "SHIFT + TAB",
  alternative_key_sequence = "SHIFT + M",
  order = "c-b",
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

data:extend{toggle_driving, direct_control, spidertron_pipette, spidertron_patrol_pipette, open_inventory, open_in_map, use_remote}