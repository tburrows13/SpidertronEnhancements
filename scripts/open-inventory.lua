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

-- Open the spidertron by clicking on it even if the player doesn't enable "interact in game"
if script.active_mods["RemoteConfiguration"] then
  script.on_event("rc-open-gui",
    function(event)
      local player = game.get_player(event.player_index)
      if player.mod_settings["rc-interact-in-game"].value then return end
      local cursor_stack = player.cursor_stack
      if (cursor_stack and cursor_stack.valid_for_read) or player.cursor_ghost then return end
      local selected = player.selected
      if selected and selected.type == "spider-vehicle" then
        remote.call("RemoteConfiguration", "open_entity", player, selected)
      end
    end
  )
end

script.on_event(defines.events.on_gui_closed,
  function(event)
    local spidertron = event.entity
    if spidertron and spidertron.type == "spider-vehicle" then
      local player = game.get_player(event.player_index)
      -- If still in range, assume that it was closed deliberately
      if remote.interfaces["RemoteConfiguration"] then
        if not remote.call("RemoteConfiguration", "reset_this_tick", player) then -- and not player.can_reach_entity(spidertron) then
          remote.call("RemoteConfiguration", "open_entity", player, spidertron)
        end
      else
        if not player.can_reach_entity(spidertron) then
          player.print({"cursor-message.spidertron-enhancements-remote-configuration-required"})
        end
      end
    end
  end
)
