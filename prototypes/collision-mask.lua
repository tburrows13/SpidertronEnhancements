-- Add custom layer to all prototypes with "player-layer" and over a certain size
local math2d = require "math2d"
local collision_mask_util_extended = require "__SpidertronEnhancements__.collision-mask-util-extended.data.collision-mask-util-extended"

local prototypes = collision_mask_util_extended.collect_prototypes_with_layer("player-layer")

local function collision_box_too_large(collision_box)
  local left_top = math2d.position.ensure_xy(collision_box[1])
  local right_bottom = math2d.position.ensure_xy(collision_box[2])
  local width = math.abs(right_bottom.x - left_top.x)
  local height = math.abs(right_bottom.y - left_top.y)
  if width > 9 and height > 9 then
    return true
  end
end

local large_entity_found = false
for _, prototype in pairs(prototypes) do
  if prototype.type ~= "tile" and (prototype.collision_box and collision_box_too_large(prototype.collision_box)) then
    log("Added large-entity-layer to entity: " .. prototype.name)
    local large_entity_layer = collision_mask_util_extended.get_make_named_collision_mask("large-entity-layer")
    local collision_mask = collision_mask_util_extended.get_mask(prototype)
    collision_mask_util_extended.add_layer(collision_mask, large_entity_layer)
    prototype.collision_mask = collision_mask
    large_entity_found = true
  end
end

if large_entity_found then
  local large_entity_layer = collision_mask_util_extended.get_named_collision_mask("large-entity-layer")
  for _, prototype in pairs(prototypes) do
    if prototype.type == "tile" then
      log("Added large-entity-layer to tile: " .. prototype.name)
      -- Tiles require collision_mask to be set
      collision_mask_util_extended.add_layer(prototype.collision_mask, large_entity_layer)
      large_entity_found = true
    end
  end
end  