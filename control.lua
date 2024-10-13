do
  -- Don't load if sim scenario has already loaded this (in another lua state)
  local modloader = remote.interfaces["modloader"]
  if modloader and modloader[script.mod_name] then
    return
  end
end

spidertron_lib = require "scripts.spidertron_lib"
require "scripts.hidden-spidertron"
local create_corpse = require "scripts.create-corpse"
require "scripts.remote-pipette"
require "scripts.open-inventory"
require "scripts.open-in-map"
require "scripts.pathfinder"
local recall_spidertron = require "scripts.recall-last-spidertron"

on_spidertron_replaced = script.generate_event_name()
remote.add_interface("SpidertronEnhancements",
  {
    get_events = function()
      return {
        on_spidertron_replaced = on_spidertron_replaced,
      }
    end
  }
)

function reset_reach_distance_bonuses()
  -- Reset reach distance bonuses from 1.8.14 and earlier
  local reach_distance_bonuses = storage.reach_distance_bonuses or {}
  for player_index, _ in pairs(reach_distance_bonuses) do
    local player = game.get_player(player_index)
    if player and player.character and (player.opened_gui_type ~= defines.gui_type.entity or player.opened.type ~= "spider-vehicle") then
      local reach_distance_bonus = player.character_reach_distance_bonus
      if reach_distance_bonus >= 100000 then
        player.character_reach_distance_bonus = player.character_reach_distance_bonus - 100000
      end
      storage.reach_distance_bonuses[player.index] = nil
    end
  end
end
script.on_event(defines.events.on_gui_opened,
  function(event)
    reset_reach_distance_bonuses()
  end
)

script.on_event(defines.events.on_object_destroyed,
  function(event)
    recall_spidertron.on_object_destroyed(event)
    create_corpse.on_object_destroyed(event)
  end
)

script.on_init(
  function()
    storage.stored_spidertrons = {}  -- Indexed by player.index
    storage.stored_spidertrons_personal = {}  -- Indexed by player.index

    storage.pathfinder_requests = {}  -- Indexed by request_id
    storage.pathfinder_statuses = {}  -- Indexed by spidertron.unit_number, then by start_tick

    storage.last_spidertron = {}  -- Indexed by player.index
    storage.destroy_registrations = {}  -- Indexed by registration number
    storage.corpse_destroy_registrations = {}  -- Indexed by registration number

    storage.vehicle_to_enter_this_tick = {}  -- Indexed by game.tick

    recall_spidertron.on_init()
  end
)

script.on_configuration_changed(
  function()
    -- Added in 1.0.0? Added here for sims after removal of simhelper
    storage.stored_spidertrons = storage.stored_spidertrons or {}
    storage.stored_spidertrons_personal = storage.stored_spidertrons_personal or {}

    -- Added in 1.3.0
    storage.pathfinder_requests = storage.pathfinder_requests or {}
    storage.pathfinder_statuses = storage.pathfinder_statuses or {}

    -- Added in 1.4.0
    storage.last_spidertron = storage.last_spidertron or {}
    storage.destroy_registrations = storage.destroy_registrations or {}
    storage.corpse_destroy_registrations = storage.corpse_destroy_registrations or {}

    storage.vehicle_to_enter_this_tick = storage.vehicle_to_enter_this_tick or {}
    storage.player_last_driving_change_tick = nil  -- Removed in v1.4.0

    storage.paths_assigned_on_tick = nil  -- Removed in v1.4.3

    -- Remove now-invalid spidertron prototypes
    for i, serialised_data in pairs(storage.stored_spidertrons_personal) do
      if not prototypes.entity[serialised_data.name] then
        storage.stored_spidertrons_personal[i] = nil
      end
    end
    for i, serialised_data in pairs(storage.stored_spidertrons) do
      if not (serialised_data.name and prototypes.entity[serialised_data.name]) then
        storage.stored_spidertrons[i] = nil
      end
    end
  end
)
