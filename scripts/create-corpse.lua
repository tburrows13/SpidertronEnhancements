local function store_inventory(inventory, inventory_stacks)
  if inventory then
    for i = 1, #inventory do
      local item_stack = inventory[i]
      if item_stack and item_stack.valid_for_read then
        table.insert(inventory_stacks, item_stack)
      end
    end
  end
end

-- Kill player upon spidertron death
function on_spidertron_died(spidertron)
  if spidertron and spidertron.valid and spidertron.name ~= "companion" then
    -- Spill all spidertron items onto the ground
    local inventory_stacks = {}

    -- Save all LuaItemStacks into one big table
    store_inventory(spidertron.get_inventory(defines.inventory.spider_trunk), inventory_stacks)
    store_inventory(spidertron.get_inventory(defines.inventory.spider_ammo), inventory_stacks)
    store_inventory(spidertron.get_inventory(defines.inventory.spider_trash), inventory_stacks)
    store_inventory(spidertron.get_inventory(defines.inventory.fuel), inventory_stacks)
    store_inventory(spidertron.get_inventory(defines.inventory.burnt_result), inventory_stacks)

    -- Save all equipment into a table
    local equipment_stacks = spidertron.grid.take_all()
    local equipment_count = 0
    for _, count in pairs(equipment_stacks) do
      equipment_count = equipment_count + count
    end

    -- Put all LuaItemStacks and equipment into a script inventory
    local temp_inventory = game.create_inventory(#inventory_stacks + equipment_count)

    for _, item_stack in pairs(inventory_stacks) do
      temp_inventory.insert(item_stack)
    end

    for name, count in pairs(equipment_stacks) do
      if name ~= "tarantulator-reactor" then
        temp_inventory.insert({name = name, count = count})
      end
    end

    -- Compress all stored items and calculate the compressed inventory size
    temp_inventory.sort_and_merge()

    local inventory_size = #temp_inventory
    for i = 1, inventory_size do
      if not temp_inventory[i].valid_for_read then
        inventory_size = i - 1
        break
      end
    end

    -- Create a corpse with the correct inventory size
    local corpse = spidertron.surface.create_entity{
      name = "spidertron-enhancements-corpse",
      position = spidertron.position,
      inventory_size = inventory_size,
    }
    corpse.color = spidertron.color  -- Doesn't work as of at least 1.1.30 (https://forums.factorio.com/viewtopic.php?f=28&t=97238)
    if string.sub(spidertron.name, 1, 20) == "spidertron-engineer-" and spidertron.last_user then
      corpse.character_corpse_player_index = spidertron.last_user.index
    end

    -- Copy across contents of the temporary inventory into the corpse inventory
    local corpse_inventory = corpse.get_inventory(defines.inventory.character_corpse)
    for i = 1, inventory_size do
      local transferred = corpse_inventory[i].transfer_stack(temp_inventory[i])
    end

    temp_inventory.destroy()
  end
end

script.on_event(defines.events.on_entity_died,
  function(event)
    if event.entity.type == "spider-vehicle" and settings.startup["spidertron-enhancements-enable-corpse"].value then
      -- Need check because filter is ignored by simulation
      on_spidertron_died(event.entity)
    end
  end,
  {{filter = "type", type = "spider-vehicle"}}
)
