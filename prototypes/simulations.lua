if not mods["SpidertronEngineer"] then
  data:extend{
    {
      type = "tips-and-tricks-item",
      name = "spidertron-enhancements",
      tag = "[entity=spidertron]",
      category = "spidertron-enhancements",
      is_title = true,
      order = "z",
      trigger = {type = "build-entity", entity = "spidertron", match_type_only = true}
    },
    {
      type = "tips-and-tricks-item",
      name = "spidertron-enhancements-enter-train",
      tag = "[entity=spidertron][entity=locomotive][entity=car]",
      category = "spidertron-enhancements",
      indent = 1,
      order = "zza",
      trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
      simulation = {
        save = "__SpidertronEnhancements__/simulations/SpidertronEnhancementsSim.zip",
        mods = {"SpidertronEnhancements"},
        init =
        [[
          local bp="0eNq9mdtu2zAMht9F185gijrYud4b7HIoCtfxUmGOHfjQrijy7pPipGkzFiExbDctFNufSVG/SFOv6qGdm/0QukmtX1Wo+25U6++vagzbrmrTb9PLvlFrFaZmpzLVVbs0GqrQqkOmQrdpfqk1HO4y1XRTmEKzPH8cvNx38+6hGeINb0/W8/DUbFZHQKb2/Rif6bv0osjRmXpR6xUUEb0JQ1Mv19wh+4OoeUTIaSQSSHxDjlOkbR+nT6ArOEHtR6gnoIYLBaShQEAtz/mVOSH1baRj22lpOy0B9WIo3ra0YEM9DaUsLcVQuG1pWnxMaklTKVMBpNSSYSpTT/asp/y2RAGZzIJmUhoFtp40kM6TM2qlUM+YUbaijCeh1G4CbEU5gaUXRbV93e/6KTw1xG5y0qiJxH4IEVItV+OSqPu2H9J9w3G4jX+/aLCucNo7a23uAE2OqHMEHTkPx5RQpdtMWeRYxpvjPzAOncbcuMKn7SUlnTFhu7lum2pY/ZibNi0Mygu2hM+OeAqjL5pNlG41Tv2eYOBlesfzRKhv/TzUaer+yXxQ1rL3Ao3keqDkoLUUykhZmp1djSWhlBy0kUL97S1GM7OrM2c9UBAnXY10fNl61/SskfEtpFBGVtZs+RkkoVR8MZdCLaPMA2loyP0G+SrxpMNUaJCZMnFJwzljCg2TWFBETRHZ2dIA6TgZFLFegAzKRS91NWz71XO1jU9+BkEilYXuKY77IV7u5ralXlIIbaVNLUXbjLm9eEwutItc10YqD3LjMloUiGPpJ4+EQaGtZMo3RlSnAkMjxgrrNEZeMlKJlKSznlXf6PKE+Fjlvy92vjbjFLpl9P8qHiMWH6k+w1SfXtR3/QVNfe5YtvxOk3v9sUctJMtWIwIfyk5diHwoW4to+VB2gYeeD2WLEwWBcsKsyIJ6Yf3DghbCopkFLYVfuxyo45d//EA5tqIsP1COrSjLD5STZjcgE7qTtkw4bU0na0Fet18NhXTCvhYwGibOS6GMLwgnbUFCybBU2oIERs3gc2EHVsNtSz0Iodfuk5ZqYfddM1qlHiXnDtowfDeic4drJCVzb4VHBNeeYzp9GevHZjO3p+OXSx8vjaF4d8NyvPNny+q5CtN93Xeb4xsXTITsq6G5P50BxQIvO58HTWGXnppC/XNMO/XhLrn2WXX49/C75OTxEGr97swqU0/NMC5TW4Dxpfa61AjoDoff7kG9Jg=="
          game.surfaces[1].create_entities_from_blueprint_string{string = bp, position = {0, 0}}

          local spidertron = game.surfaces[1].create_entity{name = "spidertron", position = {-10, 0}, force = "player"}
          spidertron.color = {0, 1, 0, 0.5}
          spidertron.torso_orientation = 0.7
          local fuel_inventory = spidertron.get_fuel_inventory()
          if fuel_inventory and game.item_prototypes["dt-fuel"] then
            fuel_inventory.insert("dt-fuel")  -- Krastorio2
          end

          local locomotive = game.surfaces[1].find_entities_filtered{name="locomotive", limit=1}[1]
          local train = locomotive.train
          locomotive.insert{name = "nuclear-fuel", count = 3}
          if game.active_mods["Krastorio2"] then
            locomotive.insert{name = "advanced-fuel", count = 600}
          end

          local player = game.create_test_player{name = "character"}
          --game.camera_player = player
          game.camera_zoom = 0.37
          game.tick_paused = false
          game.camera_alt_info = false
          spidertron.set_driver(player)

          local train_location = {-33, -4}
          spidertron.autopilot_destination = train_location

          script.on_event(defines.events.on_spider_command_completed,
            function(event)
              script.on_nth_tick(120,
                function()
                  remote.call("SpidertronEnhancementsInternal-hs", "enter-vehicles", player)
                  train.manual_mode = false
                  script.on_nth_tick(120, nil)
                end
              )
              script.on_event(defines.events.on_spider_command_completed, nil)
            end
          )

          script.on_event(defines.events.on_train_changed_state,
            function(event)
              if event.old_state == defines.train_state.arrive_station and train.station then
                log("Train arrived")
                if train.station.backer_name == "Source" then
                  train.manual_mode = true
                  locomotive.insert{name = "solid-fuel", count = 150}
                  script.on_nth_tick(120,
                    function()
                      remote.call("SpidertronEnhancementsInternal-hs", "enter-vehicles", player)
                      train.manual_mode = false
                      script.on_nth_tick(120, nil)
                    end
                  )

                elseif train.station.backer_name == "Destination" then
                  script.on_nth_tick(60,
                  function()
                    spidertron = remote.call("SpidertronEnhancementsInternal-hs", "enter-vehicles", player)
                    spidertron.autopilot_destination = train_location
                    script.on_nth_tick(60, nil)
                  end
                )
                end
              end
              log("Changed state from " .. event.old_state)
            end
          )
        ]]
      }
    },
    {
      type = "tips-and-tricks-item",
      name = "spidertron-enhancements-quick-toggle",
      tag = "[entity=spidertron][entity=character]",
      category = "spidertron-enhancements",
      indent = 1,
      order = "zzb",
      trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
      simulation = {
        mods = {"SpidertronEnhancements"},
        init =
        [[
          local spidertron = game.surfaces[1].create_entity{name = "spidertron", position = {-0.5, 1.5}, force = "player"}
          spidertron.color = {0, 1, 1, 0.5}
          --spidertron.torso_orientation = 0.4
          local player = game.create_test_player{name = "character"}

          --game.camera_player = player
          game.camera_zoom = 2
          game.tick_paused = false
          game.camera_alt_info = false
          spidertron.set_driver(player)

          script.on_nth_tick(120, function(event)
            if event.tick ~= 0 then
              remote.call("SpidertronEnhancementsInternal-hs", "enter-vehicles", player)
            end
          end)
        ]]
      }
    },
    {
      type = "tips-and-tricks-item",
      name = "spidertron-enhancements-pathfinder",
      tag = "[item=spidertron-remote]",
      category = "spidertron-enhancements",
      indent = 1,
      order = "zzc",
      trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
      simulation = {
        save = "__SpidertronEnhancements__/simulations/SpidertronEnhancementsSim.zip",
        mods = {"SpidertronEnhancements"},
        init =
        [[

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
          local fuel_inventory = spidertron.get_fuel_inventory()
          if fuel_inventory and game.item_prototypes["dt-fuel"] then
            fuel_inventory.insert("dt-fuel")  -- Krastorio2
          end

          local player = game.create_test_player{name = "character"}
          player.teleport{-26, 10}
          game.camera_player = player
          game.camera_player_cursor_position = {0, 0}

          player.cursor_stack.set_stack({name = "spidertron-remote", count = 1})
          player.cursor_stack.connected_entity = spidertron

          game.camera_zoom = 0.5
          game.tick_paused = false
          game.camera_alt_info = false

          -- Generate water tiles
          fill_tiles({-19, -70}, {-5, 10}, "water")
          fill_tiles({5, -10}, {19, 70}, "water")

          destinations = {{26, 0}, {-26, 0}}
          step_1 = function()
            script.on_nth_tick(1, function()
              local finished = game.move_cursor({position = destinations[1]})
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
              local finished = game.move_cursor({position = destinations[2]})
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
    },
    {
      type = "tips-and-tricks-item",
      name = "spidertron-enhancements-remote-pipette",
      tag = "[item=spidertron-remote]",
      category = "spidertron-enhancements",
      indent = 1,
      order = "zzd",
      trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
      simulation = {
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

          local player = game.create_test_player{name = "character"}
          player.teleport{-4, 1.5}
          game.camera_player = player
          game.camera_player_cursor_position = player.position

          --player.cursor_stack.connected_entity = spidertron

          game.camera_zoom = 2
          game.tick_paused = false
          game.camera_alt_info = false

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
              local finished = game.move_cursor({position = pipette_position})
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
            player.cursor_stack.set_stack({name = "spidertron-remote", count = 1})
            player.cursor_stack.connected_entity = spidertron
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
              local finished = game.move_cursor({position = player.position})
              if game.camera_player_cursor_position.x < -3 then
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
    },
  }
end