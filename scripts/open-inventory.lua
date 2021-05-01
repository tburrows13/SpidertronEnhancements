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

-- Allows the player to have spidertron inventories open from any distance away
open_inventory = {}
function open_inventory.on_gui_opened(event)
  local spidertron = event.entity
  if spidertron and spidertron.type == "spider-vehicle" then
    local player = game.get_player(event.player_index)
    if player.character and not global.reach_distance_bonuses[player.index] then
      player.character_reach_distance_bonus = player.character_reach_distance_bonus + 100000
      global.reach_distance_bonuses[player.index] = true
    end
  end
end

script.on_nth_tick(23,
  function()
    -- Reset reach distance bonuses
    local reach_distance_bonuses = global.reach_distance_bonuses
    for player_index, _ in pairs(reach_distance_bonuses) do
      local player = game.get_player(player_index)
      if player and player.character and (player.opened_gui_type ~= defines.gui_type.entity or player.opened.type ~= "spider-vehicle") then
        local reach_distance_bonus = player.character_reach_distance_bonus
        if reach_distance_bonus >= 100000 then
          player.character_reach_distance_bonus = player.character_reach_distance_bonus - 100000
          global.reach_distance_bonuses[player.index] = nil
        elseif not global.reach_distance_warned then
          game.print("Some mods are setting conflicting character reach bonuses. Please report this to the relevant mod authors. You will not be shown this warning again.")
          global.reach_distance_warned = true

          player.character_reach_distance_bonus = 0
          global.reach_distance_bonuses[player.index] = nil
        end
      end
    end
  end
)