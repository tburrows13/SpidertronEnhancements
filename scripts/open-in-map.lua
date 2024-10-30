script.on_event("spidertron-enhancements-open-in-map",
  function(event)
    local player = game.get_player(event.player_index)
    if player.spidertron_remote_selection then
      local spidertron = player.spidertron_remote_selection[1]
      player.set_controller{
        type = defines.controllers.remote,
        position = spidertron.position,
        surface = spidertron.surface,
      }
      player.centered_on = spidertron
    end
  end
)
