script.on_event("spidertron-enhancements-open-vehicle-inventory",
  function(event)
    local player = game.get_player(event.player_index)
    if player.opened_gui_type == defines.gui_type.none then
      local cursor_stack = player.cursor_stack
      if cursor_stack and cursor_stack.valid_for_read and cursor_stack.type == "spidertron-remote" and cursor_stack.connected_entity then
        player.opened = cursor_stack.connected_entity
      else
        local vehicle = player.vehicle
        if vehicle and vehicle.valid then
          player.opened = vehicle
        end
      end
    else
      -- Close the GUI
      player.opened = nil
    end
  end
)
