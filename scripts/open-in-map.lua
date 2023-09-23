script.on_event("spidertron-enhancements-open-in-map",
  function(event)
    local player = game.get_player(event.player_index)
    local cursor_stack = player.cursor_stack
    if cursor_stack and cursor_stack.valid_for_read and cursor_stack.type == "spidertron-remote" and cursor_stack.connected_entity then
      local vehicle = cursor_stack.connected_entity
      player.open_map(vehicle.position, (1/16) * player.display_scale, vehicle)  
    end
  end
)
