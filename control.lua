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
  end
)