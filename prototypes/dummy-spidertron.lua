-- Gets run from data, data-updates, and data-final-fixes to ensure that the dummy spidertrons are always copied from the correct spidertron prototype

local sprite_fields = {
  "upper_part",
  "lower_part",
  "upper_part_shadow",
  "lower_part_shadow",
  "upper_part_water_reflection",
  "lower_part_water_reflection",
  "joint",
  "joint_shadow",
}


local function remove_hitboxes(spidertron_leg)
  spidertron_leg.collision_box = nil
  spidertron_leg.selection_box = nil
  spidertron_leg.collision_mask = {layers = {}}
  for _, field in pairs(sprite_fields) do
    spidertron_leg.graphics_set[field] = nil
  end
  return spidertron_leg
end

local function adjust_graphics_set(graphics_set)
  graphics_set.base_render_layer = "entity-info-icon-above"
  graphics_set.render_layer = "entity-info-icon-above"

  graphics_set.base_animation = util.empty_animation(1)
  graphics_set.shadow_base_animation = util.empty_animation(1)
  return graphics_set
end

function create_dummy_spidertron(arguments)
  local spidertron = arguments.spidertron
  local scale = arguments.scale
  local leg_scale = scale * arguments.leg_scale
  local name = "spidertron-enhancements-dummy-" .. spidertron.name

  local dummy_spidertron = table.deepcopy(spidertron)
  dummy_spidertron.name = name
  dummy_spidertron.localised_name = {"entity-name.spidertron-enhancements-dummy-spidertron", spidertron.localised_name or {"entity-name." .. spidertron.name}}
  dummy_spidertron.collision_box = nil
  dummy_spidertron.sticker_box = nil
  dummy_spidertron.selection_box = {{-1 * scale, -1 * scale}, {1 * scale, 0.5 * scale}}
  dummy_spidertron.allow_passengers = false
  dummy_spidertron.allow_remote_driving = false
  dummy_spidertron.collision_mask = {layers = {}}
  dummy_spidertron.height = 0
  dummy_spidertron.alert_icon_shift = {0, 0}
  dummy_spidertron.graphics_set = adjust_graphics_set(dummy_spidertron.graphics_set)
  dummy_spidertron.spider_engine =
  {
    legs =
    {
      { -- 1
        leg = name .. "-leg-1",
        mount_position = util.by_pixel(0, 0),--{0.5, -0.75},
        ground_position = {0, 0},
        walking_group = 1,
      },
    },
  }

  data:extend(
  {
    dummy_spidertron,
    remove_hitboxes(make_spidertron_leg(name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 1)),
  })
end


-- Create a dummy spidertron for each spidertron in the game (to allow for modded spidertrons)
local spidertrons = data.raw["spider-vehicle"]
for _, spidertron in pairs(spidertrons) do
  if spidertron.allow_passengers ~= false then
    create_dummy_spidertron{spidertron = spidertron,
                            scale = 1,
                            leg_scale = 0.5,
                            leg_thickness = 1.5,
                            leg_movement_speed = 1,
    }
  end
end
-- leg_scale relative to scale
-- leg_thickness relative to leg_scale
