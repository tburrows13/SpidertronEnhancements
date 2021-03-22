do
  -- Don't load if sim scenario has already loaded this (in another lua state)
  local modloader = remote.interfaces["modloader"]
  if modloader and modloader[script.mod_name] then
    return
  end
end

spidertron_lib = require 'scripts.spidertron_lib'
require 'scripts.hidden-spidertron'
require 'scripts.auto-sort'
require 'scripts.death-spill'
require 'scripts.remote-pipette'
require 'scripts.open-inventory'
require 'scripts.pathfinder'

script.on_init(
  function()
    global.player_last_driving_change_tick = {}  -- Indexed by player.index
    global.stored_spidertrons = {}  -- Indexed by player.index
    global.stored_spidertrons_personal = {}  -- Indexed by player.index

    global.pathfinder_requests = {}  -- Indexed by request_id
    global.pathfinder_statuses = {}  -- Indexed by spidertron.unit_number, then by start_tick
    global.paths_assigned_on_tick = {}  -- Indexed by game.tick, then by spidertron.unit_number

    -- TODO Move to Spidertron Engineer
    if game.active_mods["SpidertronEngineer"] then
      settings.global["spidertron-enhancements-enter-entity-base-game"] = {value = false}
      settings.global["spidertron-enhancements-enter-entity-custom"] = {value = false}
      settings.global["spidertron-enhancements-show-spider-on-vehicle"] = {value = false}
      settings.global["spidertron-enhancements-enter-player"] = {value = false}
    end
  end
)

script.on_configuration_changed(
  function()
    -- Added in 1.3.0
    global.pathfinder_requests = global.pathfinder_requests or {}
    global.pathfinder_statuses = global.pathfinder_statuses or {}
    global.paths_assigned_on_tick = global.paths_assigned_on_tick or {}


    if game.active_mods["SpidertronEngineer"] and not script.level.is_simulation then
      settings.global["spidertron-enhancements-enter-entity-base-game"] = {value = false}
      settings.global["spidertron-enhancements-enter-entity-custom"] = {value = false}
      settings.global["spidertron-enhancements-show-spider-on-vehicle"] = {value = false}
      settings.global["spidertron-enhancements-enter-player"] = {value = false}
    end
  end
)
