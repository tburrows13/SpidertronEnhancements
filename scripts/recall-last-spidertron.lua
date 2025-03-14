SHORTCUT_NAME = "spidertron-enhancements-recall-shortcut"

---@param event EventData.on_player_driving_changed_state
function on_player_driving_changed_state(event)
  -- Called from hidden-spidertron because we can only subscribe to each event once
  local spidertron = event.entity
  -- spidertron doesn't exist if it has just died
  if spidertron and spidertron.type == "spider-vehicle" then
    local player = game.get_player(event.player_index)  ---@cast player -?
    if player.driving then
      -- Player has entered a spidertron
      local following_spidertron = storage.last_spidertron[player.index]
      if following_spidertron and following_spidertron.valid and player.character and following_spidertron.follow_target == player.character then
        following_spidertron.follow_target = nil
      end
      player.set_shortcut_toggled(SHORTCUT_NAME, false)
      player.set_shortcut_available(SHORTCUT_NAME, false)
      storage.last_spidertron[player.index] = nil
    else
      -- Player has exited a spidertron
      player.set_shortcut_available(SHORTCUT_NAME, true)
      storage.last_spidertron[player.index] = spidertron
      local reg_id = script.register_on_object_destroyed(spidertron)
      storage.destroy_registrations[reg_id] = player.index
    end
  end
end

---@param spidertron LuaEntity
function on_spidertron_given_new_destination(spidertron)
  -- Turn off the toggle for all players currently calling the spidertron
  for player_index, last_spidertron in pairs(storage.last_spidertron) do
    if last_spidertron.valid and spidertron == last_spidertron then
      local player = game.get_player(player_index)
      if player and player.valid then
        player.set_shortcut_toggled(SHORTCUT_NAME, false)
      end
    end
  end
end

script.on_event(defines.events.on_player_used_spidertron_remote,
  function(event)
    local player = game.get_player(event.player_index)  ---@cast player -?
    local spidertrons = player.spidertron_remote_selection
    if spidertrons then
      for _, spidertron in pairs(spidertrons) do
        on_spidertron_given_new_destination(spidertron)
      end
    end
  end
)

---@param event EventData.on_object_destroyed
local function on_object_destroyed(event)
  local player_index = storage.destroy_registrations[event.registration_number]
  if player_index then
    local player = game.get_player(player_index)
    if player then
      local spidertron = storage.last_spidertron[player.index]
      if not (spidertron and spidertron.valid) then
        player.set_shortcut_toggled(SHORTCUT_NAME, false)
        player.set_shortcut_available(SHORTCUT_NAME, false)
        storage.last_spidertron[player.index] = nil
      end
    end
    storage.destroy_registrations[event.registration_number] = nil
  end
end

---@param event EventData.on_lua_shortcut
local function on_shortcut_pressed(event)
  local player = game.get_player(event.player_index)  ---@cast player -?
  local spidertron = storage.last_spidertron[player.index]

  local toggle_on = not player.is_shortcut_toggled(SHORTCUT_NAME)
  if toggle_on then
    if player and player.character and spidertron and spidertron.valid then
      -- Toggle off other player's shortcuts if they were calling this spidertron
      for player_index, last_spidertron in pairs(storage.last_spidertron) do
        if last_spidertron == spidertron then
          -- That player may be calling the current spidertron
          local other_player = game.get_player(player_index)
          if other_player and other_player.character then
            if spidertron.follow_target == other_player.character then
              other_player.set_shortcut_toggled(SHORTCUT_NAME, false)
            end
          end
        end
      end

      spidertron.follow_target = player.character
      spidertron.follow_offset = {0, 0}
      player.set_shortcut_toggled(SHORTCUT_NAME, true)

    elseif player then
      player.create_local_flying_text{text = {"cursor-message.spidertron-enhancements-no-last-spidertron"}, create_at_cursor = true}
    end
  else
    if player and player.character and spidertron and spidertron.valid and spidertron.follow_target == player.character then
      spidertron.follow_target = nil
    end
    player.set_shortcut_toggled(SHORTCUT_NAME, false)
  end
end

script.on_event(SHORTCUT_NAME, on_shortcut_pressed)
script.on_event(defines.events.on_lua_shortcut,
  function(event)
    if event.prototype_name == SHORTCUT_NAME then
      on_shortcut_pressed(event)
    end
  end
)

local function on_init()
  for _, player in pairs(game.players) do
    player.set_shortcut_available(SHORTCUT_NAME, false)
  end
end

script.on_event(defines.events.on_player_created,
  function(event)
    local player = game.get_player(event.player_index)  ---@cast player -?
    player.set_shortcut_available(SHORTCUT_NAME, false)
  end
)

return {on_init = on_init, on_object_destroyed = on_object_destroyed}