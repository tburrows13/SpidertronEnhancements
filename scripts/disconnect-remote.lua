script.on_event("spidertron-enhancements-disconnect-remote",
  function(event)
    local player = game.get_player(event.player_index)
    local cursor_stack = player.cursor_stack
    if cursor_stack and cursor_stack.valid_for_read and cursor_stack.type == "spidertron-remote" then
      local spidertron = cursor_stack.connected_entity

      cursor_stack.connected_entity = nil

      script.raise_event(on_player_disconnected_spider_remote, {player_index = player.index, vehicle = spidertron})
    end

  end
)