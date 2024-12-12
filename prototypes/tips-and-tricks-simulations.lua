local simulations = {}

local insert_fuel_function = [[
  local function insert_fuel_into_vehicle(vehicle, preferred_fuel)
    local burner = vehicle.burner
    if burner then
      local fuel_categories = burner.fuel_categories
      for fuel_category, _ in pairs(fuel_categories) do
        local fuel_items = prototypes.get_item_filtered{{filter = "fuel-category", ["fuel-category"] = fuel_category}}
        if preferred_fuel and fuel_items[preferred_fuel] then
          local burner_inventory = vehicle.get_inventory(defines.inventory.fuel)
          burner_inventory.insert{name = preferred_fuel, count = 1000}
        else
          for fuel_item, _ in pairs(fuel_items) do
            local burner_inventory = vehicle.get_inventory(defines.inventory.fuel)
            burner_inventory.insert{name = fuel_item, count = 1000}
          end
        end
      end
    end
  end
]]

simulations.enter_train = {
  mods = {"SpidertronEnhancements"},
  init = insert_fuel_function .. [[
    require("__core__/lualib/story")

    game.surfaces[1].build_checkerboard{{-100, -70}, {100, 70}}
    local bp="0eNq9mc1u4jAQx9/F54Diz9g97xvscYVQCF5qbYhREuhWFe++4wRKl7rVzK7UAxAH5+exx2OP/3lhm/boD33oRvbwwkITu4E9/HhhQ9h1dZvudfXeswfW16Fl54KFbut/swd+XhXMd2MYg5+fmArP6+643/geKhTXJ5tjf/LbRQIsalawQxzgqdglOJAWQhXsGX6tA/w29L6Z/+XiXLzDilfsMAJx9zhO4ByW57EqQ5VoKnd4qsJTKzxV46kaTzV4qsRTKzyV4C2LphKc5dBQgq94iaYSfMU5mkrwFceHFsFXHB1aFCg6sij9RwcWxVXouKLMKnRYEeY/R0cVJVQ5Oqwoy4pAhxVlCRTosKIs1wIdVpStRUjs9praz1FNjqqy1E1ud70aW2E2bY3liiqPzVpr0NbK6+SSf2OzxlZYrOSv1BzHojMgeZmllUWY57DYa6eBmkt58FvTq3k6C7qFTeJ0i2GMh098AJQCmqzn/9j3eOwbD/Wb2MY+VYYvsG0H30vBtbFGVEZrXRouVSmlKCVPE2ozbRl1qqacLaWDyvDDlZFGyFIZ+4G96IB8Y3GOI+kDmJ0oUpENynNuUdbGJu7jGE7+M2tgegGj3rR+3cZdGMbQDOunxwDlfTyFDlzws24HX7DYB2js4rLyC31l6GPMs6CKPMZ5jiUbZFwW5FBRc11izN3qbd+G0DcPruvm0tf5RpXUIc2PhHpzUqz7XVw81bupI+8GVC11WdnJ6Amnl6UR+h8n8RL6J6wWruJaS1sK5Uohlax0OuOeoGbsoZXu2LY5owV5cTfmzoU5rKQu7vdUXuawirxTGo6wVlN3yntq3lpDzkL0fRaSPY5X1CzkHpulWrLQoTXGWkdWOu65WfWgJEsdKCwnax0orCCLHSisJKsdKKwiyx0orKbqHSiqoQoeKGpFFTxQVEsVPFBURxU8MFRTEgUPFJQTBQ8UVBAFDxRUEgUPFFQRBQ8UVFMFDxTVUAUPFLWiCh4oqqUKHiiqowoeGGpVUgWP99QVJM3No98e28sri9sxKZWlflNhSqB9E/vt5X3I+wPrUx3GdRO77dT6XA14h7r36/H5kEyFRLxgl+sx7NNTkJ/+GtIycV6lbn6Uxf8/fHWeOjzG5lcCdfM4XHsDd+cT46ZOV4rPxsS5cL0tdWKE0e+hjdubooKdfD9MZmsjnHJOw0dxC2emP66VgNU="
    game.surfaces[1].create_entities_from_blueprint_string{string = bp, position = {0, 0}}

    local spidertron = game.surfaces[1].create_entity{name = "spidertron", position = {-10, 0}, force = "player"}
    spidertron.color = {0, 1, 0, 0.5}
    spidertron.torso_orientation = 0.7
    insert_fuel_into_vehicle(spidertron)

    local locomotive = game.surfaces[1].find_entities_filtered{name="locomotive", limit=1}[1]
    local train = locomotive.train
    train.manual_mode = true
    insert_fuel_into_vehicle(locomotive, "nuclear-fuel")

    local player = game.simulation.create_test_player{name = "character"}
    game.simulation.camera_player = player
    game.simulation.camera_zoom = 0.54
    game.tick_paused = false
    game.simulation.camera_alt_info = false
    game.simulation.hide_cursor = true
    spidertron.set_driver(player)

    local train_location = {-31, 0.5}

    local story_table =
    {
      {
        {
          name = "start",
          condition = story_elapsed_check(0.2),
          action = function()
            insert_fuel_into_vehicle(spidertron)
            insert_fuel_into_vehicle(locomotive, "nuclear-fuel")
            spidertron.autopilot_destination = train_location
          end
        },
        {
          condition = function() return not spidertron.autopilot_destination end,
        },
        {
          condition = story_elapsed_check(1),
          action = function() remote.call("SpidertronEnhancementsInternal-hs", "enter-vehicles", player) end
        },
        {
          condition = story_elapsed_check(0.5),
          action = function() train.manual_mode = false end
        },
        {
          condition = function() return train.station and train.station.backer_name == "Destination" end,
        },
        {
          condition = story_elapsed_check(0.5),
          action = function() remote.call("SpidertronEnhancementsInternal-hs", "enter-vehicles", player) end
        },
        {
          condition = story_elapsed_check(0.5),
          action = function()
            -- spidertron becomes invalid during serialisation
            spidertron = game.surfaces[1].find_entities_filtered{name = "spidertron"}[1]
            spidertron.autopilot_destination = train_location
          end
        },
        {
          condition = function() return train.station and train.station.backer_name == "Source" end,
          action = function() train.manual_mode = true end
        },
        {
          action = function()
            story_jump_to(storage.story, "start")
          end
        }
      }
    }
    tip_story_init(story_table)
  ]]
}

simulations.quick_toggle = {
  mods = {"SpidertronEnhancements"},
  init =
  [[
    local spidertron = game.surfaces[1].create_entity{name = "spidertron", position = {-0.5, 1.5}, force = "player"}
    spidertron.color = {0, 1, 1, 0.5}
    --spidertron.torso_orientation = 0.4
    local player = game.simulation.create_test_player{name = "character"}

    --game.simulation.camera_player = player
    game.simulation.camera_zoom = 2
    game.tick_paused = false
    game.simulation.camera_alt_info = false
    spidertron.set_driver(player)

    script.on_nth_tick(120, function(event)
      if event.tick ~= 0 then
        remote.call("SpidertronEnhancementsInternal-hs", "enter-vehicles", player)
      end
    end)
  ]]
}

simulations.pathfinder = {
  -- Pathfinder fails when not using save
  save = "__SpidertronEnhancements__/simulations/SpidertronEnhancementsSim.zip",
  mods = {"SpidertronEnhancements"},
  init = insert_fuel_function .. [[
    local function fill_tiles(left_top, right_bottom, tile)
      local tiles = {}
      for i = left_top[1], right_bottom[1] do
        for j = left_top[2], right_bottom[2] do
          table.insert(tiles, {position = {i, j}, name = tile})
        end
      end
      game.surfaces[1].set_tiles(tiles)
    end
    local spidertron = game.surfaces[1].create_entity{name = "spidertron", position = {-26, 0}, force = "player"}
    spidertron.color = {1, 0, 0, 0.5}
    --spidertron.torso_orientation = 0.4
    insert_fuel_into_vehicle(spidertron)

    local player = game.simulation.create_test_player{name = "character"}
    player.teleport{-26, 10}
    game.simulation.camera_player = player
    game.simulation.camera_player_cursor_position = {0, 0}

    player.cursor_stack.set_stack({name = "spidertron-remote", count = 1})
    player.spidertron_remote_selection = {spidertron}

    game.simulation.camera_zoom = 0.5
    game.tick_paused = false
    game.simulation.camera_alt_info = false

    -- Generate water tiles
    fill_tiles({-19, -70}, {-5, 10}, "water")
    fill_tiles({5, -10}, {19, 70}, "water")

    destinations = {{26, 0}, {-26, 0}}
    step_1 = function()
      insert_fuel_into_vehicle(spidertron)
      script.on_nth_tick(1, function()
        local finished = game.simulation.move_cursor({position = destinations[1]})
        if finished then
          script.on_nth_tick(1, nil)
          step_2()
        end
      end)
    end

    step_2 = function()
      remote.call("SpidertronEnhancementsInternal-pf", "use-remote", spidertron, destinations[1])
      script.on_event(defines.events.on_spider_command_completed, function()
        if not spidertron.autopilot_destination then
          script.on_event(defines.events.on_spider_command_completed, nil)
          step_3()
        end
      end)
    end

    step_3 = function()
      script.on_nth_tick(1, function()
        local finished = game.simulation.move_cursor({position = destinations[2]})
        if finished then
          script.on_nth_tick(1, nil)
          step_4()
        end
      end)
    end

    step_4 = function()
      remote.call("SpidertronEnhancementsInternal-pf", "use-remote", spidertron, destinations[2])
      script.on_event(defines.events.on_spider_command_completed, function()
        if not spidertron.autopilot_destination then
          script.on_event(defines.events.on_spider_command_completed, nil)
          step_1()
        end
      end)
    end

    step_1()
  ]]
}

simulations.remote_pipette = {
  mods = {"SpidertronEnhancements"},
  init =
  [[
    function get_centre(box) -- copied from math2d
      local x = box.left_top.x + (box.right_bottom.x - box.left_top.x) / 2
      local y = box.left_top.y + (box.right_bottom.y - box.left_top.y) / 2
      return {x = x, y = y}
    end
    local spidertron = game.surfaces[1].create_entity{name = "spidertron", position = {3, 1.5}, force = "player"}
    spidertron.color = {0, 0.4, 1, 0.5}
    local pipette_position = get_centre(spidertron.selection_box)
    --spidertron.torso_orientation = 0.4

    local player = game.simulation.create_test_player{name = "character"}
    player.teleport{-4, 1.5}
    game.simulation.camera_player = player
    game.simulation.camera_player_cursor_position = player.position

    game.simulation.camera_zoom = 2
    game.tick_paused = false
    game.simulation.camera_alt_info = false

    step_1 = function()
      local time = 0
      script.on_nth_tick(1, function()
        time = time + 1
        if time == 60 then
          script.on_nth_tick(1, nil)
          step_2()
        end
      end)
    end

    step_2 = function()
      script.on_nth_tick(1, function()
        local finished = game.simulation.move_cursor({position = pipette_position})
        if finished then
          script.on_nth_tick(1, nil)
          step_3()
        end
      end)
    end

    step_3 = function()
      local time = 0
      script.on_nth_tick(1, function()
        time = time + 1
        if time == 60 then
          script.on_nth_tick(1, nil)
          step_4()
        end
      end)
    end


    step_4 = function()
      game.simulation.control_press{control = "spidertron-enhancements-spidertron-pipette", notify = true}
      local time = 0
      script.on_nth_tick(1, function()
        time = time + 1
        if time == 60 then
          script.on_nth_tick(1, nil)
          step_5()
        end
      end)
    end

    step_5 = function()
      script.on_nth_tick(1, function()
        local finished = game.simulation.move_cursor({position = player.position})
        if game.simulation.camera_player_cursor_position.x < -3 then
          player.cursor_stack.clear()
        end
        if finished then
          script.on_nth_tick(1, nil)
          step_1()
        end
      end)
    end

    step_1()
  ]]
}

return simulations