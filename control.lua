do
  -- Don't load if sim scenario has already loaded this (in another lua state)
  local modloader = remote.interfaces["modloader"]
  if modloader and modloader[script.mod_name] then
    return
  end
end

spidertron_lib = require "scripts.spidertron_lib"
require "scripts.hidden-spidertron"
require "scripts.auto-sort"
require "scripts.create-corpse"
require "scripts.disconnect-remote"
require "scripts.remote-pipette"
require "scripts.open-inventory"
require "scripts.pathfinder"
require "scripts.recall-last-spidertron"

on_spidertron_replaced = script.generate_event_name()
remote.add_interface("SpidertronEnhancements", {get_events = function() return {on_spidertron_replaced = on_spidertron_replaced} end})

script.on_event(defines.events.on_gui_opened,
  function(event)
    auto_sort.on_gui_opened(event)
    open_inventory.on_gui_opened(event)
  end
)

script.on_init(
  function()
    global.stored_spidertrons = {}  -- Indexed by player.index
    global.stored_spidertrons_personal = {}  -- Indexed by player.index

    global.pathfinder_requests = {}  -- Indexed by request_id
    global.pathfinder_statuses = {}  -- Indexed by spidertron.unit_number, then by start_tick

    global.last_spidertron = {}  -- Indexed by player.index
    global.destroy_registrations = {}  -- Indexed by registration number

    global.vehicle_to_enter_this_tick = {}  -- Indexed by game.tick

    global.reach_distance_bonuses = {}  -- Indexed by player.index
  end
)

script.on_configuration_changed(
  function()
    -- Added in 1.3.0
    global.pathfinder_requests = global.pathfinder_requests or {}
    global.pathfinder_statuses = global.pathfinder_statuses or {}

    -- Added in 1.4.0
    global.last_spidertron = global.last_spidertron or {}
    global.destroy_registrations = global.destroy_registrations or {}

    global.vehicle_to_enter_this_tick = global.vehicle_to_enter_this_tick or {}
    global.player_last_driving_change_tick = nil  -- Removed in v1.4.0

    global.paths_assigned_on_tick = nil  -- Removed in v1.4.3

    global.reach_distance_bonuses = global.reach_distance_bonuses or {}  -- Added in 1.5.0
  end
)
