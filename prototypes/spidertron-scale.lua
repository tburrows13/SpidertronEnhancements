
local use_big_spidertron = settings.startup["spidertron-enhancements-increase-size"].value
if use_big_spidertron then
  log("Using big spidertron")
  create_spidertron{name = "spidertron",
                    scale = 1.7,
                    leg_scale = 0.9, -- relative to scale
                    leg_thickness = 1.1, -- relative to leg_scale
                    leg_movement_speed = 0.7}
end