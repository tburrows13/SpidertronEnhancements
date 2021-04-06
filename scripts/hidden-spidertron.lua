local util = require("__core__/lualib/util")
drivable_types = {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon", "car", "spider-vehicle"}

-- Intended for SpidertronEngineer compatibility but not used because
-- SpidertronEngineer turns of all of the following features instead
remote.add_interface("SpidertronEnhancements",
  {is_spidertron_in_vehicle = function(player_index) return global.stored_spidertrons[player_index] ~= nil end}
)

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
      for _, serialised_data in pairs(global.stored_spidertrons) do
        local vehicle = serialised_data.on_vehicle
        local spidertron = serialised_data.dummy_spidertron
        if vehicle and vehicle.valid and spidertron and spidertron.valid then
          -- Extra calculations to allow for the fact that the vehicle will move after the teleport
          -- so we need to place the spidertron where the vehicle will be, not where it is now
          local position = vehicle.position
          local orientation = vehicle.orientation * 2 * math.pi
          local speed = vehicle.speed
          local y = position.y - (math.cos(orientation) * speed)
          local x = position.x + (math.sin(orientation) * speed)
          if vehicle.type == "spider-vehicle" then
            -- Spidertrons have a different orientation definition and it doesn't look good to place the rider underneath their body
            spidertron.teleport({x, y-1.4})
            spidertron.torso_orientation = vehicle.torso_orientation
          else
            spidertron.teleport({x, y})
            spidertron.torso_orientation = vehicle.orientation
          end
        end
      end
    end
  end
)


local function enter_nearby_entity(player, spidertron, override_vehicle_change)
  --local allowed_into_entities = global.allowed_into_entities
  log("Searching for nearby entities to enter")

  for radius=1, 5 do
    local nearby_entities
    nearby_entities = player.surface.find_entities_filtered{position = spidertron.position, radius = radius, type = drivable_types}
    if nearby_entities and #nearby_entities >= 1 then
      for _, entity_to_drive in pairs(nearby_entities) do
        if entity_to_drive ~= spidertron and not entity_to_drive.get_driver() and entity_to_drive.prototype.allow_passengers and spidertron.minable and spidertron.prototype.mineable_properties.minable then
          log("Found entity to drive: " .. entity_to_drive.name)
          local serialised_data = spidertron_lib.serialise_spidertron(spidertron)
          serialised_data.autopilot_destination = nil
          serialised_data.follow_target = nil
          local surface = entity_to_drive.surface

          entity_to_drive.set_driver(player)

          if entity_to_drive.valid and entity_to_drive.get_driver().player == player then
            play_smoke(surface, {entity_to_drive.position, spidertron.position})

            if settings.global["spidertron-enhancements-show-spider-on-vehicle"].value then
              serialised_data.vehicle_in = entity_to_drive
              local dummy_spidertron = surface.create_entity{
                name = "spidertron-enhancements-dummy-" .. spidertron.name,
                force = player.force,
                position = entity_to_drive.position,
                create_build_effect_smoke = true,
              }
              dummy_spidertron.active = false
              spidertron_lib.deserialise_spidertron(dummy_spidertron, serialised_data)

              -- Only store the information that is lost because we are going via the dummy
              serialised_data = {name = serialised_data.name, dummy_spidertron = dummy_spidertron, on_vehicle = entity_to_drive}
            end

            if override_vehicle_change then
              global.vehicle_to_enter_this_tick[game.tick] = global.vehicle_to_enter_this_tick[game.tick] or {}
              global.vehicle_to_enter_this_tick[game.tick][player.index] = entity_to_drive
            end

            spidertron.destroy()
            global.stored_spidertrons[player.index] = serialised_data

            entity_to_drive.surface.play_sound{path = "spidertron-enhancements-vehicle-embark", position = entity_to_drive.position}

            return true
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

  local dummy_spidertron = serialised_data.dummy_spidertron
  if dummy_spidertron then
    if dummy_spidertron.valid then
      new_serialised_data = spidertron_lib.serialise_spidertron(dummy_spidertron)
      new_serialised_data.driver = nil
      new_serialised_data.passenger = nil
      new_serialised_data.name = serialised_data.name
      old_serialised_data = serialised_data
      serialised_data = new_serialised_data
      dummy_spidertron.destroy()
    else
      -- Dummy has been mined so we can exit here
      log("Dummy Spidertron not found")
      return
    end
  end

  local surface = player.surface
  local ideal_position
  if vehicle_from and vehicle_from.valid then
    -- If the player pressed 'enter' then they will have been moved out of the way of the vehicle
    -- but we still want the spidertron to appear on the vehicle
    ideal_position = vehicle_from.position
    if vehicle_from.type == "spider-vehicle" then
      -- Prevents strange z-fighting
      ideal_position = {x = ideal_position.x - 2, y = ideal_position.y}
    end
  else
    ideal_position = player.position
  end
  local position = surface.find_non_colliding_position(serialised_data.name, ideal_position, 0, 0.1)
  local spidertron = surface.create_entity{
    name = serialised_data.name,
    position = position,
    force = serialised_data.force,
    create_build_effect_smoke=true
  }
  spidertron_lib.deserialise_spidertron(spidertron, serialised_data)
  spidertron.set_driver(player)
  play_smoke(surface, {position})
  surface.play_sound{path = "spidertron-enhancements-vehicle-disembark", position = position}

  if override_vehicle_change then
    global.vehicle_to_enter_this_tick[game.tick] = global.vehicle_to_enter_this_tick[game.tick] or {}
    global.vehicle_to_enter_this_tick[game.tick][player.index] = spidertron
  end

end

script.on_event(defines.events.on_player_driving_changed_state,
  function(event)
    on_player_driving_changed_state(event)  -- In recall-last-spidertron.lua

    local overrides = global.vehicle_to_enter_this_tick[game.tick]
    if overrides then
      local player = game.get_player(event.player_index)
      local override_entity = overrides[player.index]
      if override_entity and override_entity.valid then
        overrides[player.index] = nil
        override_entity.set_driver(player)
      end
    end
    if overrides == {} then
      global.vehicle_to_enter_this_tick[game.tick] = nil
    end
  end
)

script.on_event("spidertron-enhancements-toggle-driving",
  function(event)
    local player = game.get_player(event.player_index)

    local serialised_data = global.stored_spidertrons[player.index]
    local vehicle_from = player.vehicle

    if vehicle_from and serialised_data then
      enter_spidertron(player, serialised_data, vehicle_from, true)
      global.stored_spidertrons[player.index] = nil
      return
    end

    if vehicle_from and vehicle_from.type == "spider-vehicle" and vehicle_from.get_driver().player == player and settings.global["spidertron-enhancements-enter-entity"].value and player.mod_settings["spidertron-enhancements-enter-entity-base-game"].value then
      -- If vehicle_from has a driver then we were the passenger so we don't want to enter_nearby_entity
      enter_nearby_entity(player, vehicle_from, true)
    end
end
)

local function enter_vehicles_pressed(player, force_enter_entity)
  -- Entering a nearby vehicle has priority

  if settings.global["spidertron-enhancements-enter-entity"].value and player.mod_settings["spidertron-enhancements-enter-entity-custom"].value or force_enter_entity then
    -- Off by default
    local serialised_data = global.stored_spidertrons[player.index]
    if player.driving and serialised_data then
      enter_spidertron(player, serialised_data)
      global.stored_spidertrons[player.index] = nil
      return
    end

    local spidertron = player.vehicle
    if spidertron and spidertron.get_driver().player == player and spidertron.type == "spider-vehicle" and spidertron.minable and spidertron.prototype.mineable_properties.minable then
      entered = enter_nearby_entity(player, spidertron)
      if entered then
        return
      end
    end
  end

  if settings.global["spidertron-enhancements-enter-player"].value and not (player.driving and global.stored_spidertrons[player.index]) then
    -- Can't quick toggle if there is a spidertron riding on top of this spidertron

    local serialised_data = global.stored_spidertrons_personal[player.index]
    if not player.driving and serialised_data then
      enter_spidertron(player, serialised_data)
      global.stored_spidertrons_personal[player.index] = nil

      return
    end

    -- Enter player
    local spidertron = player.vehicle
    if spidertron and spidertron.get_driver().player == player and spidertron.type == "spider-vehicle" and spidertron.minable and spidertron.prototype.mineable_properties.minable and not global.stored_spidertrons_personal[player.index] then
      -- Only allowed if the player is the driver, not the passenger
      local serialised_data = spidertron_lib.serialise_spidertron(spidertron)
      serialised_data.autopilot_destination = nil
      serialised_data.follow_target = nil
      serialised_data.passenger = nil

      local surface = player.surface
      local teleport_position = surface.find_non_colliding_position(player.character.name, spidertron.position, 0, 0.1)
      if teleport_position then
        play_smoke(surface, {spidertron.position})
        surface.play_sound{path = "spidertron-enhancements-vehicle-embark", position = spidertron.position}
        spidertron.destroy()
        local teleported = player.teleport(teleport_position)
        global.stored_spidertrons_personal[player.index] = serialised_data
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

remote.add_interface("SpidertronEnhancementsInternal",
  {["enter-vehicles"] = function(player) enter_vehicles_pressed(player, true) return player.vehicle end}
)

