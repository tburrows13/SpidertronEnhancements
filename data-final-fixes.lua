-- In case mods like spidertron-grid mess with the spidertron inventory_size after our data-updates is run
local spidertrons = data.raw["spider-vehicle"]
for _, spidertron in pairs(spidertrons) do
  if spidertron.allow_passengers ~= false and string.sub(spidertron.name, 30) ~= "spidertron-enhancements-dummy-" then
    local name = "spidertron-enhancements-dummy-" .. spidertron.name
    local dummy_spidertron = spidertrons[name]
    if dummy_spidertron then
      dummy_spidertron.inventory_size = spidertron.inventory_size
    else
      create_dummy_spidertron{
        spidertron = spidertron,
        scale = 0.8,
        leg_scale = 0.5,
        leg_thickness = 1.5,
        leg_movement_speed = 1,
      }
    end
  end
end

-- Only set this here so that modded spidertron remotes are not affected
local remote = data.raw["spidertron-remote"]["spidertron-remote"]
remote.localised_description = {
  "item-description.spidertron-enhancements-spidertron-remote-append",
  {"item-description.spidertron-remote"},
  {"item-description.spidertron-enhancements-spidertron-remote-append-pathfinder"}
}

local patrol_remote = data.raw["spidertron-remote"]["sp-spidertron-patrol-remote"]
if patrol_remote then
  patrol_remote.localised_description = {
    "item-description.spidertron-enhancements-spidertron-remote-append",
    {"item-description.sp-spidertron-patrol-remote"},
    ""
  }
end