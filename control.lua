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
local create_corpse = require "scripts.create-corpse"
require "scripts.disconnect-remote"
require "scripts.remote-pipette"
require "scripts.open-inventory"
require "scripts.open-in-map"
require "scripts.pathfinder"
local recall_spidertron = require "scripts.recall-last-spidertron"

on_spidertron_replaced = script.generate_event_name()
on_player_disconnected_spider_remote = script.generate_event_name()
remote.add_interface("SpidertronEnhancements",
  {
    get_events = function()
      return {
        on_spidertron_replaced = on_spidertron_replaced,
        on_player_disconnected_spider_remote = on_player_disconnected_spider_remote,
      }
    end
  }
)

function reset_reach_distance_bonuses()
  -- Reset reach distance bonuses from 1.8.14 and earlier
  local reach_distance_bonuses = global.reach_distance_bonuses or {}
  for player_index, _ in pairs(reach_distance_bonuses) do
    local player = game.get_player(player_index)
    if player and player.character and (player.opened_gui_type ~= defines.gui_type.entity or player.opened.type ~= "spider-vehicle") then
      local reach_distance_bonus = player.character_reach_distance_bonus
      if reach_distance_bonus >= 100000 then
        player.character_reach_distance_bonus = player.character_reach_distance_bonus - 100000
      end
      global.reach_distance_bonuses[player.index] = nil
    end
  end
end
script.on_event(defines.events.on_gui_opened,
  function(event)
    auto_sort.on_gui_opened(event)

    reset_reach_distance_bonuses()
  end
)

script.on_event(defines.events.on_entity_destroyed,
  function(event)
    recall_spidertron.on_entity_destroyed(event)
    create_corpse.on_entity_destroyed(event)
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
    global.corpse_destroy_registrations = {}  -- Indexed by registration number

    global.vehicle_to_enter_this_tick = {}  -- Indexed by game.tick

    recall_spidertron.on_init()
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
    global.corpse_destroy_registrations = global.corpse_destroy_registrations or {}

    global.vehicle_to_enter_this_tick = global.vehicle_to_enter_this_tick or {}
    global.player_last_driving_change_tick = nil  -- Removed in v1.4.0

    global.paths_assigned_on_tick = nil  -- Removed in v1.4.3

    -- Remove now-invalid spidertron prototypes
    for i, serialised_data in pairs(global.stored_spidertrons_personal) do
      if not game.entity_prototypes[serialised_data.name] then
        global.stored_spidertrons_personal[i] = nil
      end
    end
    for i, serialised_data in pairs(global.stored_spidertrons) do
      if not (serialised_data.name and game.entity_prototypes[serialised_data.name]) then
        global.stored_spidertrons[i] = nil
      end
    end
  end
)
