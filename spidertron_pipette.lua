script.on_event("spidertron-enhancements-spidertron-pipette",
  function(event)
    local player = game.get_player(event.player_index)
    if player then
      local spidertron = player.selected
      -- Adapted from spidertron_lib.lua get_remotes()
      if spidertron and spidertron.type == "spider-vehicle" then
        local remote
        local index
        local inventory = player.get_main_inventory()
        for i = 1, #inventory do
          local item = inventory[i]
          if item.valid_for_read then  -- Check if it isn't an empty inventory slot
            if item.connected_entity == spidertron then
              remote = item
              index = i
              break
            end
          end
        end
        if remote then
          player.clear_cursor()
          player.cursor_stack.transfer_stack(remote)
          player.hand_location = {inventory = 1, slot = index}
        else
          player.create_local_flying_text{text = "Connected remote not found", create_at_cursor = true}
        end
      else
        player.create_local_flying_text{text = "Entity is not a spidertron", create_at_cursor = true}
      end
    end
  end
)