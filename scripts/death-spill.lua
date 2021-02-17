-- Kill player upon spidertron death
function on_spidertron_died(spidertron)
    if spidertron then
      -- Spill all spidertron items onto the ground
      local spidertron_items = spidertron_lib.serialise_spidertron(spidertron)
      log("Spilling spidertron items onto the ground")
      for i = 1, #spidertron_items.ammo.inventory do
        local item_stack = spidertron_items.ammo.inventory[i]
        if item_stack and item_stack.valid_for_read then
          spidertron.surface.spill_item_stack(spidertron.position, {name=item_stack.name, count=item_stack.count}, true, nil, false)
        end
      end
      for i = 1, #spidertron_items.trunk.inventory do
        local item_stack = spidertron_items.trunk.inventory[i]
        if item_stack and item_stack.valid_for_read then
          spidertron.surface.spill_item_stack(spidertron.position, {name=item_stack.name, count=item_stack.count}, true, nil, false)
        end
      end

      for _, equipment in pairs(spidertron_items.equipment) do
        spidertron.surface.spill_item_stack(spidertron.position, {name=equipment.name}, true, nil, false)
      end

      for i = 1, #spidertron_items.trash.inventory do
        local item_stack = spidertron_items.trash.inventory[i]
        if item_stack and item_stack.valid_for_read then
          spidertron.surface.spill_item_stack(spidertron.position, {name=item_stack.name, count=item_stack.count}, true, nil, false)
        end
      end

    end
  end

  script.on_event(defines.events.on_entity_died,
    function(event)
      if event.entity.type == "spider-vehicle" then
        -- Need check because filter is ignored by simulation
        on_spidertron_died(event.entity)
      end
    end,
    {{filter = "type", type = "spider-vehicle"}}
  )
