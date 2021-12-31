-- Overwrite base game functions used in create_spidertron
-- https://forums.factorio.com/viewtopic.php?f=7&t=101085

local function create_spidertron_light_cone(orientation, intensity, size, shift_adder, scale)
  local shift = { x = 0, y = (-14 + shift_adder) * scale}
  return
  {
    type = "oriented",
    minimum_darkness = 0.3,
    picture =
    {
      filename = "__core__/graphics/light-cone.png",
      priority = "extra-high",
      flags = { "light" },
      scale = 2,
      width = 200,
      height = 200
    },
    source_orientation_offset = orientation,
    --add_perspective = true,
    shift = shift,
    size = 2 * size * scale,
    intensity = 0.6 * intensity, --0.6
    color = {r = 0.92, g = 0.77, b = 0.3}
  }
end


local function scale_light_positions(positions, scale)
  local new_positions = {}
  for index, position_list in pairs(positions) do
    new_positions[index] = {}
    for index2, position in pairs(position_list) do
      local new_position = {position[1] * scale, position[2] * scale}
      new_positions[index][index2] = new_position
    end
  end
  return new_positions
end

function spidertron_torso_graphics_set(spidertron_scale)
return
  {
  base_animation =
  {
    layers =
    {
      {
        filename = "__base__/graphics/entity/spidertron/torso/spidertron-body-bottom.png",
        width = 64,
        height = 54,
        line_length = 1,
        direction_count = 1,
        scale = spidertron_scale,
        shift = util.by_pixel(0 * spidertron_scale, 0 * spidertron_scale),
        hr_version =
        {
          filename = "__base__/graphics/entity/spidertron/torso/hr-spidertron-body-bottom.png",
          width = 126,
          height = 106,
          line_length = 1,
          direction_count = 1,
          scale = 0.5 * spidertron_scale,
          shift = util.by_pixel(0 * spidertron_scale, 0 * spidertron_scale)
        }
      },
      {
        filename = "__base__/graphics/entity/spidertron/torso/spidertron-body-bottom-mask.png",
        width = 62,
        height = 46,
        line_length = 1,
        direction_count = 1,
        scale = spidertron_scale,
        apply_runtime_tint = true,
        shift = util.by_pixel(0 * spidertron_scale, 4 * spidertron_scale),
        hr_version =
        {
          filename = "__base__/graphics/entity/spidertron/torso/hr-spidertron-body-bottom-mask.png",
          width = 124,
          height = 90,
          line_length = 1,
          direction_count = 1,
          scale = 0.5 * spidertron_scale,
          apply_runtime_tint = true,
          shift = util.by_pixel(0 * spidertron_scale, 3.5 * spidertron_scale)
        }
      }
    }
  },

  shadow_base_animation =
  {
    filename = "__base__/graphics/entity/spidertron/torso/spidertron-body-bottom-shadow.png",
    width = 72,
    height = 48,
    line_length = 1,
    direction_count = 1,
    scale = spidertron_scale,
    draw_as_shadow = true,
    shift = util.by_pixel(-1 * spidertron_scale, -1 * spidertron_scale),
    hr_version =
    {
      filename = "__base__/graphics/entity/spidertron/torso/hr-spidertron-body-bottom-shadow.png",
      width = 144,
      height = 96,
      line_length = 1,
      direction_count = 1,
      scale = 0.5 * spidertron_scale,
      draw_as_shadow = true,
      shift = util.by_pixel(-1 * spidertron_scale, -1 * spidertron_scale)
    }
  },

  animation =
  {
    layers =
    {
      {
        filename = "__base__/graphics/entity/spidertron/torso/spidertron-body.png",
        width = 66,
        height = 70,
        line_length = 8,
        direction_count = 64,
        scale = spidertron_scale,
        shift = util.by_pixel(0 * spidertron_scale, -19 * spidertron_scale),
        hr_version =
        {
          filename = "__base__/graphics/entity/spidertron/torso/hr-spidertron-body.png",
          width = 132,
          height = 138,
          line_length = 8,
          direction_count = 64,
          scale = 0.5 * spidertron_scale,
          shift = util.by_pixel(0 * spidertron_scale, -19 * spidertron_scale)
        }
      },
      {
        filename = "__base__/graphics/entity/spidertron/torso/spidertron-body-mask.png",
        width = 66,
        height = 50,
        line_length = 8,
        direction_count = 64,
        scale = spidertron_scale,
        apply_runtime_tint = true,
        shift = util.by_pixel(0 * spidertron_scale, -14 * spidertron_scale),
        hr_version =
        {
          filename = "__base__/graphics/entity/spidertron/torso/hr-spidertron-body-mask.png",
          width = 130,
          height = 100,
          line_length = 8,
          direction_count = 64,
          scale = 0.5 * spidertron_scale,
          apply_runtime_tint = true,
          shift = util.by_pixel(0 * spidertron_scale, -14 * spidertron_scale)
        }
      }
    }
  },

  shadow_animation =
  {
    filename = "__base__/graphics/entity/spidertron/torso/spidertron-body-shadow.png",
    width = 96,
    height = 48,
    line_length = 8,
    direction_count = 64,
    scale = spidertron_scale,
    draw_as_shadow = true,
    shift = util.by_pixel(26 * spidertron_scale, 1 * spidertron_scale),
    hr_version =
    {
      filename = "__base__/graphics/entity/spidertron/torso/hr-spidertron-body-shadow.png",
      width = 192,
      height = 94,
      line_length = 8,
      direction_count = 64,
      scale = 0.5 * spidertron_scale,
      draw_as_shadow = true,
      shift = util.by_pixel(26 * spidertron_scale, 0.5 * spidertron_scale)
    }
  },

  water_reflection =
  {
    pictures =
    {
      filename = "__base__/graphics/entity/spidertron/torso/spidertron-body-water-reflection.png",
      width = 448,
      height = 448,
      variation_count = 1,
      scale = 0.5 * spidertron_scale,
      shift = util.by_pixel(0 * spidertron_scale, 0 * spidertron_scale)
    }
  },

  light =
  {
    {
      minimum_darkness = 0.3,
      intensity = 0.4,
      size = 25 * spidertron_scale,
      color = {r=1.0, g=1.0, b=1.0}
    },
    create_spidertron_light_cone(0,     1,    1   , -1, spidertron_scale),
    create_spidertron_light_cone(-0.05, 0.7,  0.7  , 2.5, spidertron_scale),
    create_spidertron_light_cone(0.04,  0.5,  0.45 , 5.5, spidertron_scale),
    create_spidertron_light_cone(0.06,  0.6,  0.35 , 6.5, spidertron_scale)
  },

  light_positions = scale_light_positions(require("__base__/prototypes/entity/spidertron-light-positions"), spidertron_scale),

  eye_light = {intensity = 1, size = 1 * spidertron_scale, color = {r=1.0, g=1.0, b=1.0}},-- {r=1.0, g=0.0, b=0.0}},

  render_layer = "wires-above",
  base_render_layer = "higher-object-above",

  autopilot_destination_on_map_visualisation =
  {
    filename = "__core__/graphics/spidertron-target-map-visualization.png",
    priority = "extra-high-no-scale",
    scale = 0.5,
    flags = {"icon"},
    width = 64,
    height = 64,
    line_length = 8,
    frame_count = 24,
    animation_speed = 0.5,
    run_mode = "backward",
    apply_runtime_tint = true
  },
  autopilot_destination_queue_on_map_visualisation =
  {
    filename = "__core__/graphics/spidertron-target-map-visualization.png",
    priority = "extra-high-no-scale",
    scale = 0.5,
    flags = {"icon"},
    width = 64,
    height = 64,
    line_length = 8,
    frame_count = 24,
    animation_speed = 0.5,
    run_mode = "backward",
    apply_runtime_tint = true
  },

  autopilot_path_visualisation_on_map_line_width = 2, -- in pixels
  autopilot_path_visualisation_line_width = 1 / 8, -- in tiles

  autopilot_destination_visualisation_render_layer = "object",
  autopilot_destination_visualisation =
  {
    filename = "__core__/graphics/spidertron-target-map-visualization.png",
    priority = "extra-high-no-scale",
    scale = 0.5,
    flags = {"icon"},
    width = 64,
    height = 64,
    line_length = 8,
    frame_count = 24,
    animation_speed = 0.5,
    run_mode = "backward",
    apply_runtime_tint = true
  },
  autopilot_destination_queue_visualisation =
  {
    filename = "__core__/graphics/spidertron-target-map-visualization.png",
    priority = "extra-high-no-scale",
    scale = 0.5,
    flags = {"icon"},
    width = 64,
    height = 64,
    line_length = 8,
    frame_count = 24,
    animation_speed = 0.5,
    run_mode = "backward",
    apply_runtime_tint = true
  }
}
end

local use_big_spidertron = settings.startup["spidertron-enhancements-increase-size"].value
if use_big_spidertron then
  log("Using big spidertron")
  create_spidertron{name = "spidertron",
                    scale = 1.7,
                    leg_scale = 0.9, -- relative to scale
                    leg_thickness = 1.1, -- relative to leg_scale
                    leg_movement_speed = 0.7}
end