spidertron_lib = require 'scripts.spidertron_lib'
require 'scripts.hidden-spidertron'
require 'scripts.auto-sort'
require 'scripts.death-spill'
require 'scripts.remote-pipette'

script.on_init(
  function()
    global.player_last_driving_change_tick = {}
    global.stored_spidertrons = {}
    global.stored_spidertrons_personal = {}
  end
)