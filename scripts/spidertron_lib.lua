MAP_ENTITY_INVENTORY = {["cargo-wagon"] = defines.inventory.cargo_wagon,
                        ["container"] = defines.inventory.chest,
                        ["car"] = defines.inventory.car_trunk,
                        ["character"] = defines.inventory.character_main,
                        ["logistic-container"] = defines.inventory.chest,
                        ["spider-vehicle"] = defines.inventory.spider_trunk}


local spidertron_lib = {}

local function copy_inventory(old_inventory, inventory, filter_table)
  if not inventory then
    inventory = game.create_inventory(#old_inventory)
  end

  -- Assumes that old_inventory and inventory are not both filterable
  local store_filters = false
  local load_filters = false
  if not filter_table and old_inventory.is_filtered() and not inventory.supports_filters() then
    store_filters = true
    filter_table = {}
  elseif filter_table and inventory.supports_filters() then
    load_filters = true
  end

  -- Find out where to spill excess stacks
  local entity_owner = inventory.entity_owner
  local surface, position
  if entity_owner then
    surface = entity_owner.surface
    position = entity_owner.position
  end

  local item_prototypes = prototypes.item
  local quality_prototypes = prototypes.quality
  local newsize = #inventory
  for i = 1, #old_inventory do
    if i <= newsize then
      local transferred = inventory[i].set_stack(old_inventory[i])
      if (not transferred) and surface and position then
        -- If only part of the stack was transferred then the remainder will be spilled
        surface.spill_item_stack{position=position, stack=old_inventory[i], allow_belts=false}
      end

      -- Can't set filters in script inventories, so must store them separately
      -- See https://forums.factorio.com/viewtopic.php?f=28&t=89674
      if store_filters then
        filter_table[i] = old_inventory.get_filter(i)
      end
      if load_filters and filter_table[i] and filter_table[i].name and item_prototypes[filter_table[i].name] then
        if filter_table[i].quality and not quality_prototypes[filter_table[i].quality] then
          filter_table[i].quality = nil
        end
        inventory.set_filter(i, filter_table[i])
      end
    else
      -- If the inventory is smaller than the old inventory, spill the remainder
      if surface and position then
        surface.spill_item_stack{position=position, stack=old_inventory[i], allow_belts=false}
      end
    end
  end
  return {inventory = inventory, filters = filter_table}
end
spidertron_lib.copy_inventory = copy_inventory

local function serialise_burner(burner)
  local serialised_data = {}
  serialised_data.inventory = copy_inventory(burner.inventory).inventory
  serialised_data.burnt_result_inventory = copy_inventory(burner.burnt_result_inventory).inventory
  serialised_data.heat = burner.heat
  serialised_data.currently_burning = burner.currently_burning
  serialised_data.remaining_burning_fuel = burner.remaining_burning_fuel
  return serialised_data
end

local function deserialise_burner(burner, serialised_data)
  copy_inventory(serialised_data.inventory, burner.inventory)
  copy_inventory(serialised_data.burnt_result_inventory, burner.burnt_result_inventory)
  burner.heat = serialised_data.heat
  burner.currently_burning = serialised_data.currently_burning
  burner.remaining_burning_fuel = serialised_data.remaining_burning_fuel
end


function spidertron_lib.serialise_spidertron(spidertron)
  local serialised_data = {}
  serialised_data.version = 2  -- Allows the deserialiser to know exactly what format the data is in
  serialised_data.unit_number = spidertron.unit_number
  serialised_data.name = spidertron.name
  serialised_data.quality = spidertron.quality.name

  serialised_data.driver_is_gunner = spidertron.driver_is_gunner

  local driver = spidertron.get_driver()
  if driver then
    serialised_data.driver = driver
    serialised_data.walking_state = driver.walking_state
  end

  local passenger = spidertron.get_passenger()
  if passenger then
    serialised_data.passenger = passenger
  end

  serialised_data.leg_name = spidertron.get_spider_legs()[1].name
  serialised_data.localised_name = spidertron.localised_name  -- Can be used for warnings if spidertron recreation is blocked
  serialised_data.force = spidertron.force
  serialised_data.torso_orientation = spidertron.torso_orientation
  serialised_data.last_user = spidertron.last_user
  serialised_data.color = spidertron.color
  serialised_data.entity_label = spidertron.entity_label

  serialised_data.enable_logistics_while_moving = spidertron.enable_logistics_while_moving
  serialised_data.vehicle_automatic_targeting_parameters = spidertron.vehicle_automatic_targeting_parameters

  serialised_data.autopilot_destinations = spidertron.autopilot_destinations
  serialised_data.follow_target = spidertron.follow_target
  serialised_data.follow_offset = spidertron.follow_offset
  serialised_data.selected_gun_index = spidertron.selected_gun_index

  serialised_data.health = spidertron.get_health_ratio()

  -- No 100% reliable way to check if the call is valid.
  -- `request_slot_count` returns 0 for spidertrons with no logistics, but also with no requests
  -- trash inventory size > 0 works, except it isn't updated on an already-placed spidrtron
  local status, request_from_buffers = pcall(function() return spidertron.request_from_buffers end)
  if status then
    serialised_data.request_from_buffers = request_from_buffers
  end


  -- Inventories
  serialised_data.trunk = copy_inventory(spidertron.get_inventory(defines.inventory.spider_trunk))
  serialised_data.ammo = copy_inventory(spidertron.get_inventory(defines.inventory.spider_ammo))
  serialised_data.trash = copy_inventory(spidertron.get_inventory(defines.inventory.spider_trash))

  if spidertron.burner then
    serialised_data.burner = serialise_burner(spidertron.burner)
  end

  -- Equipment grid
  local grid_contents = {}
  if spidertron.grid then
    for _, equipment in pairs(spidertron.grid.equipment) do
      local equipment_data = {name=equipment.name, quality=equipment.quality.name, position=equipment.position, energy=equipment.energy, shield=equipment.shield, to_be_removed=equipment.to_be_removed}
      if equipment.name == "equipment-ghost" then
        equipment_data.ghost_name = equipment.ghost_name
      end
      if equipment.burner then  -- e.g. BurnerGenerator mod
        equipment_data.burner = serialise_burner(equipment.burner)
      end
      table.insert(grid_contents, equipment_data)
    end
  end
  serialised_data.equipment = grid_contents

  local logistic_point = spidertron.get_logistic_point(defines.logistic_member_index.character_requester)  ---@cast logistic_point LuaLogisticPoint
  if logistic_point then
    serialised_data.logistics_enabled = logistic_point.enabled
    serialised_data.logistics_trash_not_requested = logistic_point.trash_not_requested

    local sections = {}
    for i = 1, 100 do
      local section = logistic_point.get_section(i)
      if not section then break end
      local seralised_section = {}
      seralised_section.active = section.active
      seralised_section.multiplier = section.multiplier
      if section.group ~= "" then
        seralised_section.group = section.group
      else
        seralised_section.filters = section.filters
      end
      sections[i] = seralised_section
    end
    serialised_data.logistic_sections = sections
  end

  -- Find all connected remotes in player inventories or in radius 30 around all players
  local players_selecting_spidertron = {}
  for index, player in pairs(game.players) do
    local spidertron_remote_selection = player.spidertron_remote_selection or {}
    for _, spidertron_selection in pairs(spidertron_remote_selection) do
      if spidertron_selection == spidertron then
        players_selecting_spidertron[index] = true
      end
    end
  end
  serialised_data.players_selecting_spidertron = players_selecting_spidertron

  -- Store which players had this spidertron's GUI open
  local players_with_gui_open = {}
  for _, player in pairs(game.connected_players) do
    if player.opened == spidertron then
      table.insert(players_with_gui_open, player)
    end
  end
  serialised_data.players_with_gui_open = players_with_gui_open

  return serialised_data
end


function spidertron_lib.deserialise_spidertron(spidertron, serialised_data, transfer_player_state)
  -- Copy all data in serialised_data into spidertron
  -- Set `serialised_data` fields to `nil` to prevent that attribute of `spidertron` being overwritten

  -- transfer_player_state keeps driver/passenger in spidertron, player.opened and player.walking_state intact
  -- and should be used when the mod is serialising and deserialising the spidertron on the same tick

  local data_version = serialised_data.version or 1

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

  -- Copy across fuel, remaining_burning_fuel, etc (for modded spidertrons that use fuel)
  local burner = serialised_data.burner
  if burner and spidertron.burner then
    deserialise_burner(spidertron.burner, burner)
  end

  local logistic_point = spidertron.get_logistic_point(defines.logistic_member_index.character_requester)  ---@cast logistic_point LuaLogisticPoint
  if logistic_point then
    logistic_point.enabled = serialised_data.logistics_enabled
    logistic_point.trash_not_requested = serialised_data.logistics_trash_not_requested
    for i, section in pairs(serialised_data.logistic_sections) do
      local logistic_section
      if i == 1 then
        -- First section is always present
        logistic_section = logistic_point.get_section(1)
        if section.group then
          logistic_section.group = section.group
        else
          logistic_section.filters = section.filters
        end
      else
        -- New sections beyond 1st
        if section.group then
          logistic_section = logistic_point.add_section(section.group)
        else
          logistic_section = logistic_point.add_section()
          logistic_section.filters = section.filters
        end
      end
      logistic_section.active = section.active
      logistic_section.multiplier = section.multiplier
    end
  end

  -- Copy across equipment grid
  local previous_grid_contents = serialised_data.equipment
  local spidertron_grid = spidertron.grid
  if previous_grid_contents then
    for _, equipment in pairs(previous_grid_contents) do
      if prototypes.equipment[equipment.name] then
        -- Only attempt deserialization if equipment prototype still exists
        if spidertron_grid then
          local placed_equipment
          if equipment.name == "equipment-ghost" then
            if equipment.ghost_name then  -- Legacy check
              placed_equipment = spidertron_grid.put( {name=equipment.ghost_name, quality=equipment.quality, position=equipment.position, ghost=true} )
            end
          else
            placed_equipment = spidertron_grid.put( {name=equipment.name, quality=equipment.quality, position=equipment.position} )
          end
          if placed_equipment then
            if equipment.energy then placed_equipment.energy = equipment.energy end
            if equipment.shield and equipment.shield > 0 then placed_equipment.shield = equipment.shield end
            if equipment.to_be_removed then spidertron_grid.order_removal(placed_equipment) end
            if equipment.burner and placed_equipment.burner then
              deserialise_burner(placed_equipment.burner, equipment.burner)
            end
          else  -- No space in the grid because we have moved to a smaller grid
            spidertron.surface.spill_item_stack{position=spidertron.position, stack={name=equipment.name, quality=equipment.quality}}
          end
        else   -- No space in the grid because the grid has gone entirely
          spidertron.surface.spill_item_stack{position=spidertron.position, stack={name=equipment.name, quality=equipment.quality}}
        end
      end
    end
  end

  -- Reconnect remotes
  local players_selecting_spidertron = serialised_data.players_selecting_spidertron or {}
  for player_index, _ in pairs(players_selecting_spidertron) do
    local player = game.get_player(player_index)
    if player and player.connected then
      local spidertrons_selected = player.spidertron_remote_selection or {}
      table.insert(spidertrons_selected, spidertron)
      player.spidertron_remote_selection = spidertrons_selected
    end
  end

  if transfer_player_state then
    -- Copy across driving state
    local driver = serialised_data.driver
    -- driver is a character, not player
    if driver and driver.valid then
      if driver.vehicle then  -- set_driver can fail if driver is already in a vehicle and can't exit it
        driver.vehicle.set_driver(nil)
      end
      spidertron.set_driver(driver)
    end
    -- `spidertron` could be invalid here because `.set_driver` raises an event that other mods can react to
    if not spidertron.valid then
      return  -- Will probably still crash calling function...
    end

    local passenger = serialised_data.passenger
    if passenger and passenger.valid then
      if passenger.vehicle then  -- set_driver can fail if driver is already in a vehicle and can't exit it
        passenger.vehicle.set_driver(nil)
      end
      spidertron.set_passenger(passenger)
    end
    -- Same check again here
    if not spidertron.valid then
      return
    end

    local walking_state = serialised_data.walking_state
    if driver and driver.valid and driver.object_name == "LuaEntity" and walking_state then
      -- driver is a LuaPlayer in simulations
      driver.player.walking_state = walking_state
    end

    local players_with_gui_open = serialised_data.players_with_gui_open
    if players_with_gui_open then
      -- Reopen the new GUI for players that had the old one open
      for _, player in pairs(players_with_gui_open) do
        if player.valid then
          player.opened = spidertron
        end
      end
    end
  end

end

return spidertron_lib