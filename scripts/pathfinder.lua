---@param spidertron LuaEntity
---@param start_position MapPosition
---@param target_position MapPosition
---@param clicked_position MapPosition
---@param resolution integer
---@param player LuaPlayer
---@param start_tick integer
---@param index integer
local function request_path(spidertron, start_position, target_position, clicked_position, resolution, player, start_tick, index)
  local leg = spidertron.get_spider_legs()[index]

  local leg_collision_mask = leg.prototype.collision_mask
  local path_collision_mask = {layers = leg_collision_mask.layers, colliding_with_tiles_only = true, consider_tile_transitions = true}
  --if script.active_mods["space-exploration"] then
  --  path_collision_mask.layers["empty_space_tile"] = true
  --end
  if leg_collision_mask.layers["player"] and prototypes.collision_layer["large_entity"] then
    -- "large_entity" layer is added to all >9x9 which collide with "player" layer
    -- Since we now aren't using `colliding_with_tiles_only`, can't use exact leg_collision_mask
    -- Using "large_entity" layer instead is a suitable approximation
    path_collision_mask = {layers = {large_entity = true}, colliding_with_tiles_only = false, consider_tile_transitions = true}
  end
  local request_id = spidertron.surface.request_path{
    bounding_box = {{-0.01, -0.01}, {0.01, 0.01}},
    collision_mask = path_collision_mask,
    start = {x = start_position.x, y = start_position.y},
    goal = target_position,
    force = spidertron.force,
    path_resolution_modifier = resolution,
    pathfind_flags = {prefer_straight_paths = false,
                      cache = false,
                      low_priority = false},
    entity_to_ignore = leg, -- not needed when only considering tiles
  }
  storage.pathfinder_requests[request_id] = {
    spidertron = spidertron,
    start_position = start_position,
    target_position = target_position,
    clicked_position = clicked_position,
    resolution = resolution,
    player = player,
    start_tick = start_tick,
    index = index
  }
end

---@param spidertron LuaEntity
---@param clicked_position MapPosition
---@param resolution integer
---@param player LuaPlayer
local function request_multiple_paths(spidertron, clicked_position, resolution, player)
  if util.distance(spidertron.position, clicked_position) < 10 then
    spidertron.autopilot_destination = clicked_position
    return
  end

  local spidertron_legs = spidertron.get_spider_legs()

  -- Find valid position nearby clicked position in case the user clicked on water
  local target_position = spidertron.surface.find_non_colliding_position(
    spidertron_legs[1].name,  -- prototype name
    clicked_position,  -- center
    10, -- radius
    2 -- precision
  )
  target_position = target_position or clicked_position

  -- Start paths from odd-numbered legs, at least some of which will be on valid ground
  for i, spidertron_leg in pairs(spidertron_legs) do
    if (i % 2 == 1) then
      request_path(spidertron, spidertron_leg.position, target_position, clicked_position, resolution, player, game.tick, i)
    end
  end

  storage.pathfinder_statuses[spidertron.unit_number] = storage.pathfinder_statuses[spidertron.unit_number] or {}
  storage.pathfinder_statuses[spidertron.unit_number][game.tick] = {finished = 0, success = false}
end

script.on_event(prototypes.custom_input["spidertron-enhancements-use-alt-spidertron-remote"],
  function(event)
    local player = game.get_player(event.player_index)
    if player then
      local cursor_item = player.cursor_stack
      if cursor_item and cursor_item.valid_for_read and (cursor_item.type == "spidertron-remote" and cursor_item.name ~= "sp-spidertron-patrol-remote") and player.spidertron_remote_selection then
        for _, spidertron in pairs(player.spidertron_remote_selection) do
          if spidertron and spidertron.name:sub(1, 10) ~= "ss-docked-" then
            -- Prevent remote working on docked spidertrons from Space Spidertron
            local clicked_position = event.cursor_position
            spidertron.autopilot_destination = clicked_position
            request_multiple_paths(spidertron, clicked_position, -3, player)
          end
        end
      end
    end
  end
)

remote.add_interface("SpidertronEnhancementsInternal-pf",
  ---@diagnostic disable-next-line: missing-fields
  {["use-remote"] = function(spidertron, position) request_multiple_paths(spidertron, position, -1, {valid = true}) end}
)

script.on_event(defines.events.on_script_path_request_finished,
  function(event)
    local request_info = storage.pathfinder_requests[event.id]
    if request_info then
      local spidertron = request_info.spidertron
      local player = request_info.player
      if spidertron.valid and player.valid then
        local total_legs = #spidertron.get_spider_legs()
        local total_path_requests = math.floor(total_legs / 2) + (total_legs % 2)

        local start_position = request_info.start_position
        local target_position = request_info.target_position
        local clicked_position = request_info.clicked_position
        local resolution = request_info.resolution
        local start_tick = request_info.start_tick
        local index = request_info.index

        local status_table = storage.pathfinder_statuses[spidertron.unit_number][start_tick]
        local autopilot_destination = spidertron.autopilot_destination
        if status_table.success then
          -- One of the other pathfinders succeeded
          status_table.finished = status_table.finished + 1

        elseif autopilot_destination and autopilot_destination.x ~= clicked_position.x and autopilot_destination.y ~= clicked_position.y then
          -- Something else has changed the destination so we can stop looking for a path
          --game.print(event.id .. " - Autopilot destination has been changed")
          status_table.finished = status_table.finished + 1
          status_table.success = true

        elseif event.try_again_later then
          --game.print(event.id .. " - Path request failed")
          request_path(spidertron, start_position, target_position, clicked_position, resolution, player, start_tick, index)

        elseif not event.path then
          -- No path found. Try again at a larger resolution
          --game.print(event.id .. " - No path found at resolution " .. resolution)
          if resolution < 1 then
            -- Retry with larger resolution
            request_path(spidertron, start_position, target_position, clicked_position, resolution + 2, player, start_tick, index)
          else
            status_table.finished = status_table.finished + 1
          end
          if status_table.finished == total_path_requests then
            -- All pathfinders have failed
            --spidertron.autopilot_destination = target_position

            player.create_local_flying_text{text = {"no-path"}, create_at_cursor = true}
          end
        else
          -- game.print(event.id .. " - Path found at resolution " .. resolution)
          spidertron.autopilot_destination = nil
          local last_position = spidertron.position

          --local distance_to_previous_waypoint = util.distance(last_position, event.path[1])
          event.path[1] = nil
          if clicked_position.x == target_position.x and clicked_position.y == target_position.y then
            -- Prevents the last position being added twice
            event.path[#event.path] = nil
          end

          -- Start at nearest waypoint, as path could be out of date
          local min_distance = 1000000
          local min_i = nil
          for i, waypoint in pairs(event.path) do
            local position = waypoint.position
            local distance = util.distance(last_position, position)
            if distance < min_distance then
              min_distance = distance
              min_i = i
            end
          end

          -- Heights spiderling=0.7, spidertron=1.5, spidertron-mk3=2
          -- Using height as proxy for leg spread. Distance of 15 works well for regular spidertron
          local minimum_distance_between_waypoints = (spidertron.prototype.height + 0.5) * 7.5
          for i, waypoint in pairs(event.path) do
            if i >= min_i + 1 then
              local position = waypoint.position
              if util.distance(last_position, position) > minimum_distance_between_waypoints then
                -- Each waypoint will be at least x apart from each other
                spidertron.add_autopilot_destination(position)
                last_position = position
              end
            end
          end
          spidertron.add_autopilot_destination(clicked_position)

          -- Toggles shortcut off in recall-last-spidertron
          on_spidertron_given_new_destination(spidertron)

          status_table.finished = status_table.finished + 1
          status_table.success = true
        end

        if status_table.finished == total_path_requests then
          storage.pathfinder_statuses[spidertron.unit_number][start_tick] = nil
        end

      end
      storage.pathfinder_requests[event.id] = nil
    end
  end
)