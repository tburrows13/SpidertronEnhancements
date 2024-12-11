script.on_event("spidertron-enhancements-open-vehicle-inventory",
  function(event)
    local player = game.get_player(event.player_index)  ---@cast player -?
    if player.opened_gui_type == defines.gui_type.none then
      if player.spidertron_remote_selection then
        local spidertron = player.spidertron_remote_selection[1]
        if not player.can_reach_entity(spidertron) then
          player.set_controller{
            type = defines.controllers.remote,
            position = player.position,
          }
        end
        player.opened = spidertron
      else
        local vehicle = player.vehicle or player.physical_vehicle
        if vehicle then
          player.opened = vehicle
        end
      end
    else
      -- Close the GUI
      player.opened = nil
    end
  end
)

script.on_event("spidertron-enhancements-open-gui",
  function(event)
    local player = game.get_player(event.player_index)  ---@cast player -?
    if not player.is_cursor_empty() then return end
    local selected = player.selected
    if selected and selected.type == "spider-vehicle" then
      if not player.can_reach_entity(selected) then
        player.set_controller{
          type = defines.controllers.remote,
          position = player.position,
        }
        player.opened = selected
      end
    else
      -- Try from the map for trains (and other vehicles)
      if player.render_mode == defines.render_mode.chart and not player.opened then
        -- Don't need to check chart_zoomed_in because spidertrons have radars, so would be selectable
        local position = event.cursor_position
        local vehicles = player.surface.find_entities_filtered{type = {"locomotive", "spider-vehicle"}, position = position, radius = 4.5, limit = 1}
        if #vehicles > 0 then
          player.opened = vehicles[1]
          return
        end
      end
    end
  end
)

script.on_event(defines.events.on_gui_closed,
function(event)
  local spidertron = event.entity
  if spidertron and spidertron.type == "spider-vehicle" then
    local player = game.get_player(event.player_index)  ---@cast player -?
    if not player.can_reach_entity(spidertron) then
      player.set_controller{
        type = defines.controllers.remote,
        position = player.position,
      }
      player.opened = spidertron
    end
  end
end
)