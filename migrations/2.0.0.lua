-- Migrate storage.stored_spidertrons and storage.stored_spidertrons_personal

local function copy_inventory(old_inventory, inventory, filter_table)
  -- Assumes that old_inventory and inventory are not both filterable
  local store_filters = false
  local load_filters = false
  if not filter_table and old_inventory.is_filtered() and not inventory.supports_filters() then
    store_filters = true
    filter_table = {}
  elseif filter_table and inventory.supports_filters() then
    load_filters = true
  end

  local item_prototypes = prototypes.item
  local newsize = #inventory
  for i = 1, #old_inventory do
    if i <= newsize then
      local transferred = inventory[i].set_stack(old_inventory[i])

      -- Can't set filters in script inventories, so must store them separately
      -- See https://forums.factorio.com/viewtopic.php?f=28&t=89674
      if store_filters then
        filter_table[i] = old_inventory.get_filter(i)
      end
      if load_filters and item_prototypes[filter_table[i]] then
        inventory.set_filter(i, filter_table[i])
      end
    end
  end
  return {inventory = inventory, filters = filter_table}
end

local function deserialise_spidertron(spidertron, serialised_data)
  -- Copy across generic attributes
  for _, attribute in pairs{"force",
                            "torso_orientation",
                            "last_user",
                            "color",
                            "entity_label",
                            "enable_logistics_while_moving",
                            "request_from_buffers",
                            "vehicle_automatic_targeting_parameters",
                            "follow_target",
                            "follow_offset",
                            "selected_gun_index"} do
    local value = serialised_data[attribute]
    if value ~= nil then
      spidertron[attribute] = value
    end
  end

  -- Add each autopilot destination separately
  local autopilot_destinations = serialised_data.autopilot_destinations
  if autopilot_destinations then
    for _, position in pairs(autopilot_destinations) do
      spidertron.add_autopilot_destination(position)
    end
  end

  local driver_is_gunner = serialised_data.driver_is_gunner
  if driver_is_gunner ~= nil then
    spidertron.driver_is_gunner = driver_is_gunner
  end

  -- Copy across health
  local health_ratio = serialised_data.health
  if health_ratio then
    spidertron.health = health_ratio * spidertron.max_health
  end

  -- Copy across trunk
  local previous_trunk = serialised_data.trunk
  if previous_trunk then
    local new_trunk = spidertron.get_inventory(defines.inventory.spider_trunk)
    copy_inventory(previous_trunk.inventory, new_trunk, previous_trunk.filters)
    previous_trunk.inventory.destroy()
  end

  -- Copy across ammo
  local previous_ammo = serialised_data.ammo
  if previous_ammo then
    local new_ammo = spidertron.get_inventory(defines.inventory.spider_ammo)
    copy_inventory(previous_ammo.inventory, new_ammo, previous_ammo.filters)
    previous_ammo.inventory.destroy()
  end

  -- Copy across trash
  local previous_trash = serialised_data.trash
  if previous_trash then
    local new_trash = spidertron.get_inventory(defines.inventory.spider_trash)
    copy_inventory(previous_trash.inventory, new_trash, previous_trash.filters)
    previous_trash.inventory.destroy()
  end

  -- Copy across equipment grid
  local previous_grid_contents = serialised_data.equipment
  local spidertron_grid = spidertron.grid
  if previous_grid_contents then
    for _, equipment in pairs(previous_grid_contents) do
      if prototypes.equipment[equipment.name] then
        -- Only attempt deserialization if equipment prototype still exists
        if spidertron_grid then
          local placed_equipment = spidertron_grid.put( {name=equipment.name, position=equipment.position} )
          if placed_equipment then
            if equipment.energy then placed_equipment.energy = equipment.energy end
            if equipment.shield and equipment.shield > 0 then placed_equipment.shield = equipment.shield end
          else  -- No space in the grid because we have moved to a smaller grid
            spidertron.surface.spill_item_stack{position=spidertron.position, stack={name=equipment.name}}
          end
        else   -- No space in the grid because the grid has gone entirely
          spidertron.surface.spill_item_stack{position=spidertron.position, stack={name=equipment.name}}
        end
      end
    end
  end
end

for _, player in pairs(game.players) do
  local serialised_data = storage.stored_spidertrons_personal[player.index]
  if not serialised_data then goto continue end

  if not (prototypes.entity[serialised_data.name] and prototypes.entity[serialised_data.leg_name]) then
    storage.stored_spidertrons_personal[player.index] = nil
    goto continue
  end

  local surface = player.surface

  local ideal_position = player.physical_position
  player.teleport(10, 0)

  local position = surface.find_non_colliding_position(
    serialised_data.leg_name or serialised_data.name,  -- name
    ideal_position,  -- position
    10, -- radius
    1 -- precision
    )
  player.teleport(ideal_position)

  if not position then
    goto continue
  end

  local spidertron = surface.create_entity{
    name = serialised_data.name,
    position = position,
    force = serialised_data.force,
    create_build_effect_smoke = true,
    raise_built = true,
  }

  serialised_data.driver = player.character or player  -- player does not contain a character when in a simulation
  serialised_data.passenger = nil
  serialised_data.walking_state = player.walking_state
  serialised_data.players_with_gui_open = nil
  deserialise_spidertron(spidertron, serialised_data)

  storage.stored_spidertrons_personal[player.index] = nil
  ::continue::
end