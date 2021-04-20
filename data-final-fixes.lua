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