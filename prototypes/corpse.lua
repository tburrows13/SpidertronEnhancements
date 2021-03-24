if settings.startup["spidertron-enhancements-enable-corpse"].value then
  data:extend{
    {
      type = "character-corpse",
      name = "spidertron-enhancements-corpse",
      icon = "__base__/graphics/icons/spidertron.png",
      icon_size = 64, icon_mipmaps = 4,
      minable = {mining_time = 3},
      time_to_live = 30 * 60 * 60, -- 30 minutes
      selection_box = {{-3, -3}, {3, 3}},
      selection_priority = 100, -- 0-255 value with 255 being on-top of everything else
      flags = {"placeable-off-grid", "not-rotatable", "not-on-map"},
      open_sound = { filename = "__base__/sound/character-corpse-open.ogg", volume = 0.5 },
      close_sound = { filename = "__base__/sound/character-corpse-close.ogg", volume = 0.5 },
      pictures =
      {
        {
          layers =
          {
            {
              filename = "__base__/graphics/entity/spidertron/remnants/spidertron-remnants.png",
              line_length = 1,
              width = 224,
              height = 224,
              frame_count = 1,
              variation_count = 1,
              axially_symmetrical = false,
              direction_count = 1,
              shift = util.by_pixel(0, 0),
              hr_version =
              {
                filename = "__base__/graphics/entity/spidertron/remnants/hr-spidertron-remnants.png",
                line_length = 1,
                width = 448,
                height = 448,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(0, 0),
                scale = 0.5
              }
            },
            {
              priority = "low",
              filename = "__base__/graphics/entity/spidertron/remnants/mask/spidertron-remnants-mask.png",
              width = 184,
              height = 176,
              frame_count = 1,
            -- tint = { r = 0.869, g = 0.5  , b = 0.130, a = 0.5 },
              apply_runtime_tint = true,
              direction_count = 1,
              shift = util.by_pixel(9, 1),
              hr_version=
              {
                priority = "low",
                filename = "__base__/graphics/entity/spidertron/remnants/mask/hr-spidertron-remnants-mask.png",
                width = 366,
                height = 350,
                frame_count = 1,
                --tint = { r = 0.869, g = 0.5  , b = 0.130, a = 0.5 },
                apply_runtime_tint = true,
                direction_count = 1,
                shift = util.by_pixel(9, 1),
                scale = 0.5
              }
            }
          }
        }
      }
    }
  }

  -- Better to hide existing corpse graphics than to remove the corpse entity
  --data.raw["spider-vehicle"]["spidertron"].corpse = nil
  data.raw.corpse["spidertron-remnants"].animation = nil
end