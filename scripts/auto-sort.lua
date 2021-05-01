local function sort_inventory(entity)
  if settings.global["spidertron-enhancements-auto-sort-inventory"].value then
    if entity and entity.object_name == "LuaEntity" and entity.type == "spider-vehicle" then
      entity.get_inventory(defines.inventory.spider_trunk).sort_and_merge()
    end
  end
end

auto_sort = {}
function auto_sort.on_gui_opened(event)
  sort_inventory(event.entity)
end

script.on_event({defines.events.on_player_main_inventory_changed, defines.events.on_player_cursor_stack_changed},
  function(event)
    local player = game.get_player(event.player_index)
    sort_inventory(player.opened)
  end
)