local function pipette_remote(event, remote_name)
  if not prototypes.item[remote_name] then return end
  local player = game.get_player(event.player_index)
  if player then
    if not player.is_cursor_empty() then
      player.clear_cursor()
      player.play_sound{path = "utility/clear_cursor"}
      return
    end

    local spidertron = player.selected
    if not (spidertron and spidertron.type == "spider-vehicle") then
      -- Try from the map
      if player.render_mode == defines.render_mode.chart then
        -- Don't need to check chart_zoomed_in because spidertrons have radars, so would be selectable
        local position = event.cursor_position
        local spidertrons = player.surface.find_entities_filtered{type = "spider-vehicle", position = position, radius = 9, limit = 1}
        if #spidertrons > 0 then
          spidertron = spidertrons[1]
        end
      end
    end
    if not (spidertron and spidertron.type == "spider-vehicle") then
      -- Try the player's current vehicle
      spidertron = player.vehicle
    end

    if spidertron and spidertron.type == "spider-vehicle" then
      if remote_name == "spidertron-remote" then
        local cursor = player.cursor_stack
        cursor.set_stack("spidertron-remote")
        player.spidertron_remote_selection = {spidertron}
        player.play_sound{path = "utility/smart_pipette"}
      elseif remote_name == "sp-spidertron-patrol-remote" then
        -- Let SP handle it so that it can manage the blinking paths
        remote.call("SpidertronPatrols", "give_patrol_remote", player, spidertron)
        player.play_sound{path = "utility/smart_pipette"}
      end
    else
      player.create_local_flying_text{text = {"cursor-message.spidertron-enhancements-entity-not-spidertron"}, create_at_cursor = true}
      player.play_sound{path = "utility/cannot_build"}
    end
  end
end

script.on_event("spidertron-enhancements-spidertron-pipette",
  function(event)
    pipette_remote(event, script.active_mods["nullius"] and "nullius-mecha-remote" or "spidertron-remote")
  end
)
script.on_event("spidertron-enhancements-spidertron-patrol-pipette",
  function(event)
    pipette_remote(event, "sp-spidertron-patrol-remote")
  end
)
