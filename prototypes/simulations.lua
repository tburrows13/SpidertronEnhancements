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
      tag = "[entity=spidertron]",
      category = "spidertron-enhancements",
      indent=1,
      order = "zza",
      trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
      simulation = {
        save = "__SpidertronEnhancements__/simulations/SpidertronEnhancementsSim.zip",
        init = [[
          local bp="0eNq9mdtu2zAMht9F185gijrYud4b7HIoCtfxUmGOHfjQrijy7pPipGkzFiExbDctFNufSVG/SFOv6qGdm/0QukmtX1Wo+25U6++vagzbrmrTb9PLvlFrFaZmpzLVVbs0GqrQqkOmQrdpfqk1HO4y1XRTmEKzPH8cvNx38+6hGeINb0/W8/DUbFZHQKb2/Rif6bv0osjRmXpR6xUUEb0JQ1Mv19wh+4OoeUTIaSQSSHxDjlOkbR+nT6ArOEHtR6gnoIYLBaShQEAtz/mVOSH1baRj22lpOy0B9WIo3ra0YEM9DaUsLcVQuG1pWnxMaklTKVMBpNSSYSpTT/asp/y2RAGZzIJmUhoFtp40kM6TM2qlUM+YUbaijCeh1G4CbEU5gaUXRbV93e/6KTw1xG5y0qiJxH4IEVItV+OSqPu2H9J9w3G4jX+/aLCucNo7a23uAE2OqHMEHTkPx5RQpdtMWeRYxpvjPzAOncbcuMKn7SUlnTFhu7lum2pY/ZibNi0Mygu2hM+OeAqjL5pNlG41Tv2eYOBlesfzRKhv/TzUaer+yXxQ1rL3Ao3keqDkoLUUykhZmp1djSWhlBy0kUL97S1GM7OrM2c9UBAnXY10fNl61/SskfEtpFBGVtZs+RkkoVR8MZdCLaPMA2loyP0G+SrxpMNUaJCZMnFJwzljCg2TWFBETRHZ2dIA6TgZFLFegAzKRS91NWz71XO1jU9+BkEilYXuKY77IV7u5ralXlIIbaVNLUXbjLm9eEwutItc10YqD3LjMloUiGPpJ4+EQaGtZMo3RlSnAkMjxgrrNEZeMlKJlKSznlXf6PKE+Fjlvy92vjbjFLpl9P8qHiMWH6k+w1SfXtR3/QVNfe5YtvxOk3v9sUctJMtWIwIfyk5diHwoW4to+VB2gYeeD2WLEwWBcsKsyIJ6Yf3DghbCopkFLYVfuxyo45d//EA5tqIsP1COrSjLD5STZjcgE7qTtkw4bU0na0Fet18NhXTCvhYwGibOS6GMLwgnbUFCybBU2oIERs3gc2EHVsNtSz0Iodfuk5ZqYfddM1qlHiXnDtowfDeic4drJCVzb4VHBNeeYzp9GevHZjO3p+OXSx8vjaF4d8NyvPNny+q5CtN93Xeb4xsXTITsq6G5P50BxQIvO58HTWGXnppC/XNMO/XhLrn2WXX49/C75OTxEGr97swqU0/NMC5TW4Dxpfa61AjoDoff7kG9Jg=="
          game.surfaces[1].create_entities_from_blueprint_string{string = bp, position = {0, 0}}

          local spidertron = game.surfaces[1].create_entity{name = "spidertron", position = {-10, 0}, force = "player"}
          spidertron.color = {0, 1, 0, 0.5}
          spidertron.torso_orientation = 0.7

          local locomotive = game.surfaces[1].find_entities_filtered{name="locomotive", limit=1}[1]
          local train = locomotive.train
          locomotive.insert{name = "nuclear-fuel", count = 3}

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
                  remote.call("SpidertronEnhancementsInternal", "enter-vehicles", player)
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
                      remote.call("SpidertronEnhancementsInternal", "enter-vehicles", player)
                      train.manual_mode = false
                      script.on_nth_tick(120, nil)
                    end
                  )  

                elseif train.station.backer_name == "Destination" then
                  script.on_nth_tick(60,
                  function()
                    spidertron = remote.call("SpidertronEnhancementsInternal", "enter-vehicles", player)
                    spidertron.autopilot_destination = train_location
                    script.on_nth_tick(60, nil)
                  end
                )
                end
              end
              log("Changed state from " .. event.old_state)
            end
          )
            ]],
      }
    },
  }
end