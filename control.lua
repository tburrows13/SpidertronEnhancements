spidertron_lib = require 'scripts.spidertron_lib'
require 'scripts.hidden-spidertron'
require 'scripts.auto-sort'
require 'scripts.death-spill'
require 'scripts.remote-pipette'
require 'scripts.open-inventory'

script.on_init(
  function()
    global.player_last_driving_change_tick = {}  -- Indexed by player.index
    global.stored_spidertrons = {}  -- Indexed by player.index
    global.stored_spidertrons_personal = {}  -- Indexed by player.index

    if game.active_mods["SpidertronEngineer"] then
      settings.global["spidertron-enhancements-enter-entity-base-game"] = {value = false}
      settings.global["spidertron-enhancements-enter-entity-custom"] = {value = false}
      settings.global["spidertron-enhancements-enter-player"] = {value = false}
    end
  end
)

script.on_configuration_changed(
  function()
    if game.active_mods["SpidertronEngineer"] then
      settings.global["spidertron-enhancements-enter-entity-base-game"] = {value = false}
      settings.global["spidertron-enhancements-enter-entity-custom"] = {value = false}
      settings.global["spidertron-enhancements-enter-player"] = {value = false}
    end
  end
)