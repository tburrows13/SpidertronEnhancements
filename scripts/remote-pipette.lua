script.on_event("spidertron-enhancements-spidertron-pipette",
  function(event)
    local player = game.get_player(event.player_index)
    if player then
      local spidertron = player.selected
      -- Adapted from spidertron_lib.lua get_remotes()
      if spidertron and spidertron.type == "spider-vehicle" then
        local remote
        local index
        local at_least_one_remote_found = false
        local inventory = player.get_main_inventory()
        for i = 1, #inventory do
          local item = inventory[i]
          if item.valid_for_read and item.type == "spidertron-remote" then  -- Check if it isn't an empty inventory slot
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
              if item.type == "spidertron-remote" and not item.connected_entity then
                item.connected_entity = spidertron
                remote = item
                index = i
                break
              end
            end
          end
        end
        if remote then
          player.clear_cursor()
          player.cursor_stack.transfer_stack(remote)
          player.hand_location = {inventory = 1, slot = index}
          player.play_sound{path = "utility/smart_pipette"}
        else
          if at_least_one_remote_found then
            player.create_local_flying_text{text = {"cursor-message.spidertron-enhancements-connected-remote-not-found"}, create_at_cursor = true}
          else
            player.create_local_flying_text{text = {"cursor-message.spidertron-enhancements-remote-not-found"}, create_at_cursor = true}
          end
          player.play_sound{path = "utility/cannot_build"}
        end
      else
        player.create_local_flying_text{text = {"cursor-message.spidertron-enhancements-entity-not-spidertron"}, create_at_cursor = true}
        player.play_sound{path = "utility/cannot_build"}
      end
    end
  end
)