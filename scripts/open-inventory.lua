script.on_event("spidertron-enhancements-open-vehicle-inventory",
  function(event)
    local player = game.get_player(event.player_index)
    if player.opened_gui_type == defines.gui_type.none then
      if player.spidertron_remote_selection then
        player.opened = player.spidertron_remote_selection[1]
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
