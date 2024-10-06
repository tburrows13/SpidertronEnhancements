require "prototypes.sound-edits"
require "prototypes.collision-mask"
require "prototypes.dummy-spidertron"

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
local remote_name = "spidertron-remote"
--[[ TODO Nullius 2.0 compatibility
if mods["nullius"] then remote_name = "nullius-mecha-remote" end
]]

local remote = data.raw["spidertron-remote"][remote_name]
if remote then
  local font_start = "[font=default-semibold][color=255, 230, 192]"
  local font_end = "[/color][/font]"
  local line_start = "\n  •   "
  remote.localised_description = {
    "",
    {"item-description." .. remote_name},
    "\n",
    font_start,
    {"gui.instruction-when-in-cursor"},
    ":",
    --line_start,
    {"item-description.spe-open-inventory"},
    --line_start,
    {"item-description.spe-open-in-map"},
    --line_start,
    {"item-description.spe-use-pathfinder"},
    font_end,
  }
end
