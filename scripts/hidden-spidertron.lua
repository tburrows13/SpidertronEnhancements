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


local function enter_nearby_entity(player, spidertron)
  --local allowed_into_entities = global.allowed_into_entities
  log("Searching for nearby entities to enter")

  for radius=1,6 do
    local nearby_entities
    nearby_entities = player.surface.find_entities_filtered{position = spidertron.position, radius = radius, type = drivable_types}
    if nearby_entities and #nearby_entities >= 1 then
      for i, entity_to_drive in pairs(nearby_entities) do
        if entity_to_drive ~= spidertron then
          log("Found entity to drive: " .. entity_to_drive.name)
          local serialised_data = spidertron_lib.serialise_spidertron(spidertron)
          serialised_data.autopilot_destination = nil
          serialised_data.follow_target = nil
          local surface = entity_to_drive.surface
          play_smoke(surface, {entity_to_drive.position, spidertron.position})

          entity_to_drive.set_driver(player)

          if settings.global["spidertron-enhancements-show-spider-on-vehicle"].value then
            serialised_data.vehicle_in = entity_to_drive
            local dummy_spidertron = surface.create_entity{
              name = "spidertron-enhancements-dummy-" .. spidertron.name,
              force = player.force,
              position = entity_to_drive.position,
              create_build_effect_smoke = true,
            }
            dummy_spidertron.active = false
            serialised_data.player_occupied = nil
            serialised_data.passenger = nil
            spidertron_lib.deserialise_spidertron(dummy_spidertron, serialised_data)

            -- Only store the information that is lost because we are going via the dummy
            serialised_data = {name = serialised_data.name, dummy_spidertron = dummy_spidertron, on_vehicle = entity_to_drive}
          end

          spidertron.destroy()
          global.stored_spidertrons[player.index] = serialised_data

          entity_to_drive.surface.play_sound{path = "spidertron-enhancements-vehicle-embark", position = entity_to_drive.position}

          return true
        end
      end
    end
  end
  return false
end

local function enter_spidertron(player, serialised_data, use_vehicle_position)
  -- The player just got out of a vehicle and needs to be put back into their spidertron
  -- serialised_data may contain all the data, or just name and dummy_spidertron

  local old_serialised_data
  local dummy_spidertron = serialised_data.dummy_spidertron
  if dummy_spidertron then
    if dummy_spidertron.valid then
      new_serialised_data = spidertron_lib.serialise_spidertron(dummy_spidertron)
      new_serialised_data.player_occupied = nil
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
  if use_vehicle_position and old_serialised_data then
    -- If the player pressed 'enter' then they will have been moved out of the way of the vehicle
    -- but we still want the spidertron to appear on the vehicle
    local previous_vehicle = old_serialised_data.on_vehicle
    if previous_vehicle and previous_vehicle.valid then
      ideal_position = previous_vehicle.position
    else
      ideal_position = player.position
    end
  else
    ideal_position = player.position
  end
  local position = surface.find_non_colliding_position(serialised_data.name, ideal_position, 0, 0.5)
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

end

script.on_event(defines.events.on_player_driving_changed_state,
  function(event)
    -- Hack to stop recursive calling of event and to stop calling of event interrupting ensure_player_is_in_correct_spidertron
    if settings.global["spidertron-enhancements-enter-entity-base-game"].value and global.player_last_driving_change_tick[event.player_index] ~= event.tick then
      global.player_last_driving_change_tick[event.player_index] = event.tick
      local player = game.get_player(event.player_index)

      local serialised_data = global.stored_spidertrons[player.index]
      if not player.driving and serialised_data then
        enter_spidertron(player, serialised_data, true)
        global.stored_spidertrons[player.index] = nil
        return
      end

      local spidertron = event.entity
      if (not player.driving) and spidertron and spidertron.type == "spider-vehicle" then
        enter_nearby_entity(player, spidertron)
      end
    else
      log("Driving state already changed this tick")
    end
  end
)

script.on_event("spidertron-enhancements-enter-vehicles",
  function(event)
    local player = game.get_player(event.player_index)
    global.player_last_driving_change_tick[event.player_index] = event.tick

    -- Entering a nearby vehicle has priority
    if settings.global["spidertron-enhancements-enter-entity-custom"].value then

      local serialised_data = global.stored_spidertrons[player.index]
      if player.driving and serialised_data then
        enter_spidertron(player, serialised_data)
        global.stored_spidertrons[player.index] = nil
        return
      end

      local spidertron = player.vehicle
      if spidertron and spidertron.type == "spider-vehicle" then
        entered = enter_nearby_entity(player, spidertron)
        if entered then
          return
        end
      end
    end

    if settings.global["spidertron-enhancements-enter-player"].value then
      local serialised_data = global.stored_spidertrons_personal[player.index]
      if not player.driving and serialised_data then
        enter_spidertron(player, serialised_data)
        global.stored_spidertrons_personal[player.index] = nil

        return
      end

      local spidertron = player.vehicle

      if player.driving and spidertron.type == "spider-vehicle" and not global.stored_spidertrons_personal[player.index] then
        local serialised_data = spidertron_lib.serialise_spidertron(spidertron)
        serialised_data.autopilot_destination = nil
        serialised_data.follow_target = nil
        player.driving = false
        player.teleport(spidertron.position)
        play_smoke(player.surface, {player.position})
        player.surface.play_sound{path = "spidertron-enhancements-vehicle-embark", position = player.position}
        spidertron.destroy()
        global.stored_spidertrons_personal[player.index] = serialised_data
      end
    end
  end
)
