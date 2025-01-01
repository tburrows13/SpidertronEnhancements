SPIDERTRON_NAME = {"spe-dynamic-entity-name.spidertron-lowercase"}
SPIDERTRON_NAME_CAPITALISED = {"entity-name.spidertron"}
if mods["maraxsis"] or mods["lex-aircraft"] then
  SPIDERTRON_NAME = {"spe-dynamic-entity-name.vehicle-lowercase"}
  SPIDERTRON_NAME_CAPITALISED = {"spe-dynamic-entity-name.vehicle"}
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
