-- Modify spidertron working sounds
local spidertrons = data.raw["spider-vehicle"]
for _, prototype in pairs(spidertrons) do
  local working_sound = prototype.working_sound
  if working_sound and working_sound.sound and working_sound.sound.filename == "__base__/sound/spidertron/spidertron-vox.ogg" then
    -- average pause is in seconds
    -- base game probability is 1, so average_pause default is 0
    local average_pause = settings.startup["spidertron-enhancements-sound-pause"].value
    working_sound.probability = 1 / (average_pause * 60 + 1)

    working_sound.sound.volume = working_sound.sound.volume * settings.startup["spidertron-enhancements-volume-scale"].value
  end
end
