local smoke_animations = require "__base__/prototypes/entity/smoke-animations"

data:extend{
  {
    type = "sound",
    name = "spidertron-enhancements-vehicle-disembark",
    filename = "__base__/sound/spidertron/spidertron-activate.ogg",
    volume = 0.6  -- 0.5 in base
  },
  {
    type = "sound",
    name = "spidertron-enhancements-vehicle-embark",
    filename = "__base__/sound/spidertron/spidertron-deactivate.ogg",
    volume = 0.6  -- 0.5 in base
  }
}

-- Calls generator function from base.prototypes.entity.smoke-animations.lua
local smoke = smoke_animations.trivial_smoke{
  name = "spidertron-enhancements-transition-smoke",
  duration = 50,
  fade_away_duration = 30,
  spread_duration = 15,
  start_scale = 1,
  end_scale = 2.5,
  color = {r=0.9, g=0.9, b=0.9, a=0.7},
  affected_by_wind = false
}
-- For some reason the default shift values of {-0.53125, -0.4375} is off center
smoke.animation.shift = {-0.2, -0.3}
data:extend{smoke}
