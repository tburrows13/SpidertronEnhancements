local function pipette_remote(event, remote_name)
  if not game.item_prototypes[remote_name] then return end
  local player = game.get_player(event.player_index)
  if player then
    if not player.is_cursor_empty() then
      player.clear_cursor()
      player.play_sound{path = "utility/clear_cursor"}
      return
    end

    local spidertron = player.selected
    if not (spidertron and spidertron.type == "spider-vehicle") then
      -- Try from the map
      if player.render_mode == defines.render_mode.chart then
        -- Don't need to check chart_zoomed_in because spidertrons have radars, so would be selectable
        local position = event.cursor_position
        local spidertrons = player.surface.find_entities_filtered{type = "spider-vehicle", position = position, radius = 9, limit = 1}
        if #spidertrons > 0 then
          spidertron = spidertrons[1]
        end
      end
    end
    if not (spidertron and spidertron.type == "spider-vehicle") then
      -- Try the player's current vehicle
      spidertron = player.vehicle
    end

    if spidertron and spidertron.type == "spider-vehicle" then
      if remote_name == "spidertron-remote" and settings.global["spidertron-enhancements-pipette-temporary-remote"].value then
        local cursor = player.cursor_stack
        cursor.set_stack("spidertron-enhancements-temporary-" .. remote_name)
        cursor.connected_entity = spidertron
        player.play_sound{path = "utility/smart_pipette"}
      elseif remote_name == "sp-spidertron-patrol-remote" then
        -- Patrol remote is always free/temporary
        local cursor = player.cursor_stack
        cursor.set_stack(remote_name)
        cursor.connected_entity = spidertron
        player.play_sound{path = "utility/smart_pipette"}
      else
        -- Adapted from spidertron_lib.lua get_remotes()
        local remote
        local index
        local at_least_one_remote_found = false
        local inventory = player.get_main_inventory()
        for i = 1, #inventory do
          local item = inventory[i]
          if item.valid_for_read and item.name == remote_name then  -- Check if it isn't an empty inventory slot
            at_least_one_remote_found = true
            if item.connected_entity == spidertron then
              remote = item
              index = i
              break
            end
          end
        end
        if not remote and at_least_one_remote_found and player.mod_settings["spidertron-enhancements-pipette-unconnected-remote"].value then
          -- Search didn't find connected remote, so look for new one
          for i = 1, #inventory do
            local item = inventory[i]
            if item.valid_for_read then  -- Check if it isn't an empty inventory slot
              if item.name == remote_name and not item.connected_entity then
                item.connected_entity = spidertron
                remote = item
                index = i
                break
              end
            end
          end
        end
        if remote then
          player.cursor_stack.transfer_stack(remote)
          player.hand_location = {inventory = inventory.index, slot = index}
          player.play_sound{path = "utility/smart_pipette"}
        else
          if at_least_one_remote_found then
            player.create_local_flying_text{text = {"cursor-message.spidertron-enhancements-connected-remote-not-found"}, create_at_cursor = true}
          else
            player.create_local_flying_text{text = {"cursor-message.spidertron-enhancements-remote-not-found"}, create_at_cursor = true}
          end
          player.play_sound{path = "utility/cannot_build"}
        end
      end
    else
      player.create_local_flying_text{text = {"cursor-message.spidertron-enhancements-entity-not-spidertron"}, create_at_cursor = true}
      player.play_sound{path = "utility/cannot_build"}
    end
  end
end

script.on_event("spidertron-enhancements-spidertron-pipette",
  function(event)
    pipette_remote(event, script.active_mods["nullius"] and "nullius-mecha-remote" or "spidertron-remote")
  end
)
script.on_event("spidertron-enhancements-spidertron-patrol-pipette",
  function(event)
    pipette_remote(event, "sp-spidertron-patrol-remote")
  end
)
