-- Kill player upon spidertron death
function on_spidertron_died(spidertron)
  if spidertron and spidertron.valid then
    -- Spill all spidertron items onto the ground
    local spidertron_items = spidertron_lib.serialise_spidertron(spidertron)
    log("Spilling spidertron items onto the ground")
    local inventory_stacks = {}
    for i = 1, #spidertron_items.ammo.inventory do
      local item_stack = spidertron_items.ammo.inventory[i]
      if item_stack and item_stack.valid_for_read then
        table.insert(inventory_stacks, {name=item_stack.name, count=item_stack.count})
      end
    end

    for i = 1, #spidertron_items.trunk.inventory do
      local item_stack = spidertron_items.trunk.inventory[i]
      if item_stack and item_stack.valid_for_read then
        table.insert(inventory_stacks, {name=item_stack.name, count=item_stack.count})
      end
    end

    for _, equipment in pairs(spidertron_items.equipment) do
      table.insert(inventory_stacks, {name=equipment.name, count=1})
    end

    for i = 1, #spidertron_items.trash.inventory do
      local item_stack = spidertron_items.trash.inventory[i]
      if item_stack and item_stack.valid_for_read then
        table.insert(inventory_stacks, {name=item_stack.name, count=item_stack.count})
      end
    end
    log("Spidertron died with items ", serpent.block(inventory_stacks))
    
    local corpse = spidertron.surface.create_entity{
      name = "spidertron-enhancements-corpse",
      position = spidertron.position,
      inventory_size = #inventory_stacks,
    }

    corpse.color = spidertron.color  -- Doesn't work in 1.1.27 (https://forums.factorio.com/viewtopic.php?f=28&t=97238)

    local corpse_inventory = corpse.get_inventory(defines.inventory.character_corpse)
    for i = 1, #inventory_stacks do
      local transferred = corpse_inventory[i].set_stack(inventory_stacks[i])
      log(transferred)
    end

    if string.sub(spidertron.name, 1, 20) == "spidertron-engineer-" and spidertron.last_user then
      corpse.character_corpse_player_index = spidertron.last_user.index
    end
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
