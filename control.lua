spidertron_lib = require 'spidertron_lib'
require 'spidertron_in_entity'
require 'spill_on_death'

script.on_init(
  function()
    global.player_last_driving_change_tick = {}
    global.stored_spidertrons = {}
    global.stored_spidertrons_personal = {}
  end
)