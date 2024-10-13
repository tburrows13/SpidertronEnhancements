local util = require("__core__/lualib/util")

-- Intended for SpidertronEngineer compatibility but not used because
-- SpidertronEngineer turns off all of the following features instead
--[[
  remote.add_interface("SpidertronEnhancements",
  {is_spidertron_in_vehicle = function(player_index) return storage.stored_spidertrons[player_index] ~= nil end}
)
]]

local is_rolling_stock = {
  ["locomotive"] = true,
  ["cargo-wagon"] = true,
  ["fluid-wagon"] = true,
  ["artillery-wagon"] = true,
}

local function filtered_drivable_types()
  allowed_entities_setting = settings.global["spidertron-enhancements-enter-entity"].value
  if allowed_entities_setting == "all-except-spidertrons" then  -- Default path
    return {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon", "car"}
  elseif allowed_entities_setting == "trains" then
    return {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"}
  elseif allowed_entities_setting == "all" then
    return {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon", "car", "spider-vehicle"}
  else
    return {}
  end
end

local function play_smoke(surface, positions)
  for _ = 1, 6 do
    -- Plays 6 smokes in the same area to make a thick cloud
    if #positions == 2 and util.distance(positions[1], positions[2]) < 0.3 then
      -- Don't do 2 smoke clouds in the 'same' location
      positions = {positions[1]}
    end
    for _, position in pairs(positions) do
      surface.create_trivial_smoke{name = "spidertron-enhancements-transition-smoke", position = position}
    end
  end
end

script.on_event(defines.events.on_tick,
  function()
    if settings.global["spidertron-enhancements-show-spider-on-vehicle"].value then
      for _, serialised_data in pairs(storage.stored_spidertrons) do
        local vehicle = serialised_data.on_vehicle
        local spidertron = serialised_data.dummy_spidertron
        if vehicle and vehicle.valid and spidertron and spidertron.valid then
          local position
          local orientation
          if is_rolling_stock[vehicle.type] then
            -- Trains are actually drawn at a different position to their entity position, exposed in draw_data
            local draw_data = vehicle.draw_data
            position = draw_data.position
            position = {x = position.x, y = position.y - 0.85}
            orientation = draw_data.orientation
          elseif vehicle.type == "spider-vehicle" then
            -- Spidertrons have a different orientation definition and it doesn't look good to place the rider underneath their body
            position = vehicle.position
            position = {x = position.x, y = position.y - vehicle.prototype.height - 0.35}
            orientation = vehicle.torso_orientation
          else
            -- type == "car"
            position = vehicle.position
            if vehicle.name == "tank" then
              position = {x = position.x, y = position.y - 0.95}
            else
              position = {x = position.x, y = position.y - 0.4}
            end
            orientation = vehicle.orientation
          end

          -- Extra calculations to allow for the fact that the vehicle will move after the teleport
          -- so we need to place the spidertron where the vehicle will be, not where it is now
          local calc_orientation = orientation * 2 * math.pi
          local speed = vehicle.speed
          local y = position.y - (math.cos(calc_orientation) * speed)
          local x = position.x + (math.sin(calc_orientation) * speed)
          spidertron.teleport({x, y})
          spidertron.torso_orientation = orientation
        end
      end
    end
  end
)


local function enter_nearby_entity(player, spidertron, override_vehicle_change)
  --local allowed_into_entities = storage.allowed_into_entities
  --log("Searching for nearby entities to enter")

  if remote.interfaces["aai-vehicles-ironclad"] and remote.interfaces["aai-vehicles-ironclad"].disable_this_tick then
    remote.call("aai-vehicles-ironclad", "disable_this_tick", player.index)
  end
  if remote.interfaces["cargo-ships-enter"] and remote.interfaces["cargo-ships-enter"].disable_this_tick then
    remote.call("cargo-ships-enter", "disable_this_tick", player.index)
  end


  for radius=1, 5 do
    local nearby_entities
    nearby_entities = player.surface.find_entities_filtered{position = spidertron.position, radius = radius, type = filtered_drivable_types()}
    if nearby_entities and #nearby_entities >= 1 then
      for _, entity_to_drive in pairs(nearby_entities) do
        if entity_to_drive ~= spidertron and not entity_to_drive.get_driver() and entity_to_drive.prototype.allow_passengers and spidertron.prototype.mineable_properties.minable and entity_to_drive.name:sub(1, 3) ~= "se-" then
          --log("Found entity to drive: " .. entity_to_drive.name)
          local serialised_data = spidertron_lib.serialise_spidertron(spidertron)
          serialised_data.autopilot_destination = nil
          serialised_data.follow_target = nil
          local surface = entity_to_drive.surface

          entity_to_drive.set_driver(player)
          -- After setting driver we need to revalidate everything
          if entity_to_drive.valid then
            local driver = entity_to_drive.get_driver()
            if driver and driver.object_name == "LuaEntity" and driver.player == player then
              play_smoke(surface, {entity_to_drive.position, spidertron.position})

              if override_vehicle_change then
                storage.vehicle_to_enter_this_tick[game.tick] = storage.vehicle_to_enter_this_tick[game.tick] or {}
                storage.vehicle_to_enter_this_tick[game.tick][player.index] = entity_to_drive
              end

              if settings.global["spidertron-enhancements-show-spider-on-vehicle"].value then
                serialised_data.vehicle_in = entity_to_drive
                local dummy_spidertron = surface.create_entity{
                  name = "spidertron-enhancements-dummy-" .. serialised_data.name,
                  force = player.force,
                  position = entity_to_drive.position,
                  create_build_effect_smoke = true,
                  raise_built = true,
                }
                dummy_spidertron.active = false

                -- Has to be a specific order:
                -- Raise event when both spidertrons are valid
                -- Destroy spidertron before deserialising into new one because deserialise_spidertron does checks on remote connected_entity validity
                script.raise_event(on_spidertron_replaced, {old_spidertron = spidertron, new_spidertron = dummy_spidertron})
                spidertron.destroy()
                spidertron_lib.deserialise_spidertron(dummy_spidertron, serialised_data)

                -- Only store the information that is lost because we are going via the dummy
                serialised_data = {name = serialised_data.name, dummy_spidertron = dummy_spidertron, on_vehicle = entity_to_drive, leg_name = serialised_data.leg_name}
              else
                spidertron.destroy()
              end


              storage.stored_spidertrons[player.index] = serialised_data

              entity_to_drive.surface.play_sound{path = "spidertron-enhancements-vehicle-embark", position = entity_to_drive.position}

              return true
            end
          end
        end
      end
    end
  end
  return false
end

local function enter_spidertron(player, serialised_data, vehicle_from, override_vehicle_change)
  -- The player just got out of a vehicle and needs to be put back into their spidertron
  -- serialised_data may contain all the data, or just name and dummy_spidertron
  -- vehicle_from is a LuaEntity from on_player_driving_changed_state

  if remote.interfaces["aai-vehicles-ironclad"] and remote.interfaces["aai-vehicles-ironclad"].disable_this_tick then
    remote.call("aai-vehicles-ironclad", "disable_this_tick", player.index)
  end
  if remote.interfaces["cargo-ships-enter"] and remote.interfaces["cargo-ships-enter"].disable_this_tick then
    remote.call("cargo-ships-enter", "disable_this_tick", player.index)
  end

  local dummy_spidertron = serialised_data.dummy_spidertron
  if dummy_spidertron then
    if dummy_spidertron.valid then
      new_serialised_data = spidertron_lib.serialise_spidertron(dummy_spidertron)
      new_serialised_data.driver = nil
      new_serialised_data.passenger = nil
      new_serialised_data.name = serialised_data.name
      new_serialised_data.leg_name = serialised_data.leg_name
      old_serialised_data = serialised_data
      serialised_data = new_serialised_data
    else
      -- Dummy has been mined so we can exit here
      log("Dummy Spidertron not found")
      return true
    end
  end

  local surface = player.surface
  local ideal_position
  local player_position = player.position
  if vehicle_from and vehicle_from.valid then
    -- If the player pressed 'enter' then they will have been moved out of the way of the vehicle
    -- but we still want the spidertron to appear on the vehicle
    ideal_position = vehicle_from.position
    if vehicle_from.type == "spider-vehicle" then
      -- Prevents strange z-fighting
      ideal_position = {x = ideal_position.x - 2, y = ideal_position.y}
    end
  else
    ideal_position = player_position
  end

  -- Teleport player out of the way so that it isn't in the way of the collision check
  player.teleport(10, 0)

  local position = surface.find_non_colliding_position(
    serialised_data.leg_name or serialised_data.name,  -- name
    ideal_position,  -- position
    10, -- radius
    1 -- precision
    )
  player.teleport(player_position)

  if not position then
    player.create_local_flying_text{
      text = {"cursor-message.spidertron-enhancements-cannot-create-spidertron", serialised_data.localised_name or prototypes.entity[serialised_data.name].localised_name},
      position = ideal_position
    }
    return false
  end
  local spidertron = surface.create_entity{
    name = serialised_data.name,
    position = position,
    force = serialised_data.force,
    create_build_effect_smoke = true,
    raise_built = true,
  }

  if dummy_spidertron then
    script.raise_event(on_spidertron_replaced, {old_spidertron = dummy_spidertron, new_spidertron = spidertron})
    dummy_spidertron.destroy()
  end

  serialised_data.driver = player.character or player  -- player does not contain a character when in a simulation
  serialised_data.passenger = nil
  serialised_data.walking_state = player.walking_state
  serialised_data.players_with_gui_open = nil
  spidertron_lib.deserialise_spidertron(spidertron, serialised_data, true)

  play_smoke(surface, {position})
  surface.play_sound{path = "spidertron-enhancements-vehicle-disembark", position = position}

  if override_vehicle_change then
    storage.vehicle_to_enter_this_tick[game.tick] = storage.vehicle_to_enter_this_tick[game.tick] or {}
    storage.vehicle_to_enter_this_tick[game.tick][player.index] = spidertron
  end

  return true
end

script.on_event(defines.events.on_player_driving_changed_state,
  function(event)
    on_player_driving_changed_state(event)  -- In recall-last-spidertron.lua

    local overrides = storage.vehicle_to_enter_this_tick[game.tick]
    if overrides then
      local player = game.get_player(event.player_index)
      local override_entity = overrides[player.index]
      if override_entity and override_entity.valid then
        overrides[player.index] = nil
        override_entity.set_driver(player)
      end
    end
    if overrides == {} then
      storage.vehicle_to_enter_this_tick[game.tick] = nil
    end
  end
)

script.on_event("spidertron-enhancements-toggle-driving",
  function(event)
    local player = game.get_player(event.player_index)

    local serialised_data = storage.stored_spidertrons[player.index]
    local vehicle_from = player.vehicle

    if vehicle_from and serialised_data then
      local entered = enter_spidertron(player, serialised_data, vehicle_from, true)
      if entered then
        storage.stored_spidertrons[player.index] = nil
      end
      return
    end

    if vehicle_from and vehicle_from.type == "spider-vehicle" then
      local driver = vehicle_from.get_driver()
      if driver and driver.object_name == "LuaEntity" and driver.player == player and settings.global["spidertron-enhancements-enter-entity"].value ~= "none" and player.mod_settings["spidertron-enhancements-enter-entity-base-game"].value then
        -- render_mode is proxy for LuaPlayer (vs character). If vehicle_from has a driver then we were the passenger so we don't want to enter_nearby_entity
        enter_nearby_entity(player, vehicle_from, true)
      end
    end
end
)

local function enter_vehicles_pressed(player, force_enter_entity)
  -- Entering a nearby vehicle has priority

  if settings.global["spidertron-enhancements-enter-entity"].value ~= "none" and player.mod_settings["spidertron-enhancements-enter-entity-custom"].value or force_enter_entity then
    -- Off by default
    local serialised_data = storage.stored_spidertrons[player.index]
    if player.driving and serialised_data then
      local entered = enter_spidertron(player, serialised_data)
      if entered then
        storage.stored_spidertrons[player.index] = nil
      end
      return
    end

    local spidertron = player.vehicle
    if spidertron then
      local driver = spidertron.get_driver()
      if driver and driver.object_name == "LuaEntity" and driver.player == player and spidertron.type == "spider-vehicle" and spidertron.prototype.mineable_properties.minable then
        entered = enter_nearby_entity(player, spidertron)
        if entered then
          return
        end
      end
    end
  end

  if settings.global["spidertron-enhancements-enter-player"].value and not (player.driving and storage.stored_spidertrons[player.index]) then
    -- Can't quick toggle if there is a spidertron riding on top of this spidertron

    local serialised_data = storage.stored_spidertrons_personal[player.index]
    if not player.driving and serialised_data then
      if player.character then
        -- Ensures player is not in editor mode or Space Exploration star map
        if not (remote.interfaces["jetpack"] and remote.call("jetpack", "get_jetpacks", {surface_index = player.surface.index})[player.character.unit_number]) then
          -- Ensures player isn't in Jetpack
          local entered = enter_spidertron(player, serialised_data)
          if entered then
            storage.stored_spidertrons_personal[player.index] = nil
          end
        end
      end
      return
    end

    -- Enter player
    local spidertron = player.vehicle
    if spidertron then
      local driver = spidertron.get_driver()
      if driver and driver.object_name == "LuaEntity" and driver.player == player and spidertron.type == "spider-vehicle" and spidertron.prototype.mineable_properties.minable then
          -- Only allowed if the player is the driver, not the passenger
        local personal_serialised_data = storage.stored_spidertrons_personal[player.index]
        if personal_serialised_data then
          player.create_local_flying_text{
            text = {"cursor-message.spidertron-enhancements-player-contains-spidertron", personal_serialised_data.localised_name or prototypes.entity[serialised_data.name].localised_name},
            position = {spidertron.position.x, spidertron.position.y - 2.5}
          }
        else
          -- Try and handle active robots
          local logistic_cell = spidertron.logistic_cell
          if logistic_cell then
            local charging_robots = logistic_cell.charging_robots
            local to_charge_robots = logistic_cell.to_charge_robots
            if next(charging_robots) or next(to_charge_robots) then
              -- Put charging robots back into the spidertron's inventory
              local inventory = spidertron.get_inventory(defines.inventory.spider_trunk)
              for _, robot in pairs(charging_robots) do
                robot.mine{inventory = inventory, force = false, raise_destroyed = true, ignore_minable = false}
              end
              for _, robot in pairs(to_charge_robots) do
                robot.mine{inventory = inventory, force = false, raise_destroyed = true, ignore_minable = false}
              end
            end

            local logistic_network = logistic_cell.logistic_network
            if logistic_network then
              local active_robots = #logistic_network.construction_robots
              if active_robots > 0 then
                player.create_local_flying_text{
                  text = {"cursor-message.spidertron-enhancements-robots-left-behind", active_robots},
                  position = {spidertron.position.x, spidertron.position.y - 2.5}
                }
              end
            end
          end

          local serialised_data = spidertron_lib.serialise_spidertron(spidertron)
          serialised_data.autopilot_destination = nil
          serialised_data.follow_target = nil
          serialised_data.passenger = nil

          local surface = player.surface
          driver = player.character or player  -- Simulation shenanigans
          local teleport_position = surface.find_non_colliding_position(driver.name, spidertron.position, 20, 0.1, true)
          if teleport_position then
            --script.raise_event(on_spidertron_replaced, {old_spidertron = spidertron})
            play_smoke(surface, {spidertron.position})
            surface.play_sound{path = "spidertron-enhancements-vehicle-embark", position = spidertron.position}
            spidertron.destroy()
            player.teleport(teleport_position)
            storage.stored_spidertrons_personal[player.index] = serialised_data
          end
        end
      end
    end
  end
end

script.on_event("spidertron-enhancements-enter-vehicles",
  function(event)
    local player = game.get_player(event.player_index)
    enter_vehicles_pressed(player)
  end
)

remote.add_interface("SpidertronEnhancementsInternal-hs",
  {["enter-vehicles"] = function(player) enter_vehicles_pressed(player, true) return player.vehicle end}
)

