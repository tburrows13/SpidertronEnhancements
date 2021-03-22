local function request_path(spidertron, start_position, target_position, resolution, player, start_tick, index)

  local request_id = spidertron.surface.request_path{
    bounding_box = {{-0.01, -0.01}, {0.01, 0.01}},
    collision_mask = {"water-tile", "colliding-with-tiles-only", "consider-tile-transitions"},
    start = {x = start_position.x, y = start_position.y},
    goal = target_position,
    force = spidertron.force,
    path_resolution_modifier = resolution,
    pathfind_flags = {prefer_straight_paths = false,
                      cache = false,
                      low_priority = false}
  }
  global.pathfinder_requests[request_id] = {
    spidertron = spidertron,
    start_position = start_position,
    target_position = target_position,
    resolution = resolution,
    player = player,
    start_tick = start_tick,
    index = index
  }
end

local function request_multiple_paths(spidertron, target_position, resolution, player)
  if util.distance(spidertron.position, target_position) < 15 then
    spidertron.autopilot_destination = target_position
    return
  end

  local start_positions = {}

  -- Try multiple positions because the spidertron might be above water when we start
  local spidertron_position = spidertron.position
  local x, y = spidertron_position.x, spidertron_position.y
  for i = -1, 1 do
    for j = -1, 1 do
      table.insert(start_positions, {x = x + i * 10, y = y + j * 10})
    end
  end

  for i, start_position in pairs(start_positions) do
    --[[
    rendering.draw_circle{color = {r = 0.5, g = 0, b = 0, a = 0.9},
      radius = 0.4,
      filled = true,
      surface = spidertron.surface,
      target = start_position,
      time_to_live = 300
    }
    ]]

    request_path(spidertron, start_position, target_position, resolution, player, game.tick, i)
  end

  global.pathfinder_statuses[spidertron.unit_number] = global.pathfinder_statuses[spidertron.unit_number] or {}
  global.pathfinder_statuses[spidertron.unit_number][game.tick] = {finished = 0, success = false}
end

script.on_event(defines.events.on_player_used_spider_remote,
  function(event)
    -- Is this needed? Maybe?
    local paths = global.paths_assigned_on_tick[event.tick]
    if paths then
      local spidertron = event.vehicle
      local path = paths[spidertron.unit_number]
      if path then
        spidertron.autopilot_destination = nil
        -- game.print(event.tick .. " - Re-adding destinations")
        for _, position in pairs(path) do
          spidertron.add_autopilot_destination(position)
        end
      end
      global.paths_assigned_on_tick[event.tick] = nil
    end
  end
)

script.on_event("spidertron-enhancements-use-alt-spidertron-remote",
    function(event)
      local player = game.get_player(event.player_index)
      if player then
        local cursor_item = player.cursor_stack
        if cursor_item and cursor_item.valid_for_read and cursor_item.name == "spidertron-remote" then
          local spidertron = cursor_item.connected_entity
          if spidertron then
            spidertron.autopilot_destination = nil
            request_multiple_paths(spidertron, event.cursor_position or event.position, -3, player)
          end
        end
      end
    end
)

script.on_event(defines.events.on_script_path_request_finished,
  function(event)
    local request_info = global.pathfinder_requests[event.id]
    if request_info then
      local spidertron = request_info.spidertron
      local player = request_info.player
      if spidertron.valid and player.valid then
        local start_position = request_info.start_position
        local target_position = request_info.target_position
        local resolution = request_info.resolution
        local start_tick = request_info.start_tick
        local index = request_info.index

        local status_table = global.pathfinder_statuses[spidertron.unit_number][start_tick]
        local autopilot_destination = spidertron.autopilot_destination
        if status_table.success then
          -- One of the other pathfinders succeeded
          status_table.finished = status_table.finished + 1

        elseif autopilot_destination and autopilot_destination.x ~= target_position.x and autopilot_destination.y ~= target_position.y then
          -- Something else has changed the destination so we can stop looking for a path
          --game.print(event.id .. " - Autopilot destination has been changed")
          status_table.finished = status_table.finished + 1
          status_table.success = true

        elseif event.try_again_later then
          --game.print(event.id .. " - Path request failed")
          request_path(spidertron, start_position, target_position, resolution, player, start_tick, index)

        elseif not event.path then
          -- No path found. Try again at a larger resolution
          --game.print(event.id .. " - No path found at resolution " .. resolution)
          spidertron.autopilot_destination = target_position
          if resolution < 3 then
            -- Retry with larger resolution
            request_path(spidertron, start_position, target_position, resolution + 2, player, start_tick, index)
          else
            status_table.finished = status_table.finished + 1
          end
          if status_table.finished == 9 then
            -- All 9 pathfinders have failed
            player.create_local_flying_text{text = {"no-path"}, create_at_cursor = true}
          end
        else
          -- game.print(event.id .. " - Path found at resolution " .. resolution)
          spidertron.autopilot_destination = nil
          event.path[1] = nil
          event.path[#event.path] = nil
          local last_position = spidertron.position
          for _, waypoint in pairs(event.path) do
            local position = waypoint.position
            if util.distance(last_position, position) > 25 then
              -- Each waypoint will be at least 25 apart from each other
              spidertron.add_autopilot_destination(position)
              last_position = position
            end
          end
          spidertron.add_autopilot_destination(target_position)

          global.paths_assigned_on_tick[game.tick+1] = global.paths_assigned_on_tick[game.tick+1] or {}
          table.insert(global.paths_assigned_on_tick[game.tick+1], spidertron.autopilot_destinations)

          status_table.finished = status_table.finished + 1
          status_table.success = true
        end

        if status_table.finished == 9 then
          global.pathfinder_statuses[spidertron.unit_number][start_tick] = nil
        end

      end
      global.pathfinder_requests[event.id] = nil
    end
  end
)