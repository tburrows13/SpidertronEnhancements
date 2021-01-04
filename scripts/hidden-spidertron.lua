
train_names = {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"}
drivable_names = {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon", "car", "spider-vehicle"}

remote.add_interface("SpidertronEnhancements",
  {is_spidertron_in_vehicle = function(player_index) return global.stored_spidertrons[player_index] ~= nil end}
)

local function enter_nearby_entity(player, spidertron)
  --local allowed_into_entities = global.allowed_into_entities
  log("Searching for nearby entities to enter")

  for radius=1,6 do
    local nearby_entities
    nearby_entities = player.surface.find_entities_filtered{position=spidertron.position, radius=radius, type=drivable_names}
    if nearby_entities and #nearby_entities >= 1 then
      for i, entity_to_drive in pairs(nearby_entities) do
        if entity_to_drive ~= spidertron then
          log("Found entity to drive: " .. entity_to_drive.name)
          local serialised_data = spidertron_lib.serialise_spidertron(spidertron)
          serialised_data.autopilot_destination = nil
          serialised_data.follow_target = nil
          entity_to_drive.set_driver(player)
          spidertron.destroy()
          global.stored_spidertrons[player.index] = serialised_data
          return true
        end
      end
    end
  end
  return false
end

local function enter_spidertron(player, serialised_data)
  -- The player just got out of a vehicle and needs to be put back into their spidertron

  local surface = player.surface
  local position = surface.find_non_colliding_position(serialised_data.name, player.position, 0, 0.5)
  local spidertron = surface.create_entity{
    name = serialised_data.name,
    position = position,
    force = serialised_data.force,
    create_build_effect_smoke=true
  }
  spidertron_lib.deserialise_spidertron(spidertron, serialised_data)
  spidertron.set_driver(player)

end

script.on_event(defines.events.on_player_driving_changed_state,
  function(event)
    -- Hack to stop recursive calling of event and to stop calling of event interrupting ensure_player_is_in_correct_spidertron
    if settings.global["spidertron-enhancements-enter-entity-base-game"].value and global.player_last_driving_change_tick[event.player_index] ~= event.tick then
      global.player_last_driving_change_tick[event.player_index] = event.tick
      local player = game.get_player(event.player_index)

      local serialised_data = global.stored_spidertrons[player.index]
      if not player.driving and serialised_data then
        enter_spidertron(player, serialised_data)
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
        spidertron.destroy()
        global.stored_spidertrons_personal[player.index] = serialised_data
      end
    end
  end
)
