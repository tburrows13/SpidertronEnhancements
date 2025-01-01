if settings.startup["spidertron-enhancements-enable-corpse"].value then
  data:extend{
    {
      type = "character-corpse",
      name = "spidertron-enhancements-corpse",
      localised_name = {"entity-name.spidertron-enhancements-corpse", SPIDERTRON_NAME_CAPITALISED},
      icon = "__base__/graphics/icons/spidertron.png",
      icon_size = 64,
      minable = {mining_time = 3},
      time_to_live = 30 * 60 * 60, -- 30 minutes
      selection_box = {{-3, -3}, {3, 3}},
      selection_priority = 100, -- 0-255 value with 255 being on-top of everything else
      flags = {"placeable-off-grid", "not-rotatable", "not-on-map"},
      open_sound = { filename = "__base__/sound/character-corpse-open.ogg", volume = 0.5 },
      close_sound = { filename = "__base__/sound/character-corpse-close.ogg", volume = 0.5 },
      render_layer = "corpse",
      picture = util.empty_sprite()  -- Graphics are provided by "corpse" entity
    }
  }
end