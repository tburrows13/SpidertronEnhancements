script.on_event("spidertron-enhancements-open-in-map",
  function(event)
    local player = game.get_player(event.player_index)
    if player.spidertron_remote_selection then
      local spidertron = player.spidertron_remote_selection[1]
      if player.surface == spidertron.surface then
        player.open_map(spidertron.position, (1/16) * player.display_scale, spidertron)
      else
        -- Player and spidertron are on different surfaces - try using SE navsat
        if remote.interfaces["space-exploration"] and remote.interfaces["space-exploration"]["remote_view_is_unlocked"] and
          remote.call("space-exploration", "remote_view_is_unlocked", { player = player }) then
          surface_name = spidertron.surface.name:gsub("^%l", string.upper)
          remote.call("space-exploration", "remote_view_start", {player = player, zone_name = surface_name, position = spidertron.position})
          if remote.call("space-exploration", "remote_view_is_active", { player = player }) then
            -- remote_view_start worked
            player.close_map()
          end
        end
      end
    end
  end
)
