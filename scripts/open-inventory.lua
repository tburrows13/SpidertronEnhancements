script.on_event("spidertron-enhancements-open-vehicle-inventory",
  function(event)
    local player = game.get_player(event.player_index)
    local vehicle = player.vehicle
    if vehicle and vehicle.valid then
      if player.opened == vehicle then
        -- Close the GUI
        player.opened = nil
      else
        player.opened = vehicle
      end
    end
  end
)
