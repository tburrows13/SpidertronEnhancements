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
