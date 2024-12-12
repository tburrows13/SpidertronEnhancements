require "prototypes.dummy-spidertron"

local spidertron_requires_fuel = settings.startup["spidertron-enhancements-spiderton-requires-fuel"].value
if spidertron_requires_fuel == "Yes" then
  local spidertron = data.raw["spider-vehicle"]["spidertron"]
  spidertron.energy_source = {
    type = "burner",
    fuel_categories = {"chemical"},
    effectivity = 1,
    fuel_inventory_size = 3,
  }
  spidertron.movement_energy_consumption = "800kW"
  spidertron.alert_icon_shift = {0, 0}
elseif spidertron_requires_fuel == "No" then
  local spidertron = data.raw["spider-vehicle"]["spidertron"]
  spidertron.energy_source = {
    type = "void"
  }
end