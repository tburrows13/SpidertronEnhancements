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
  spidertron_leg.collision_mask = {}
  for _, field in pairs(sprite_fields) do
    spidertron_leg.graphics_set[field] = nil
  end
  return spidertron_leg
end

local function adjust_render_layer(graphics_set)
  graphics_set.base_render_layer = "entity-info-icon"
  graphics_set.render_layer = "entity-info-icon"
  return graphics_set
end

local function create_dummy_spidertron(arguments)
  local spidertron = arguments.spidertron
  local scale = arguments.scale
  local leg_scale = scale * arguments.leg_scale
  local name = "spidertron-enhancements-dummy-" .. spidertron.name
  data:extend(
  {
    {
      type = "spider-vehicle",
      name = name,
      -- localised_name transforms e.g. "Spidertron MK2" into "Travelling Spidretron MK2"
      localised_name = {"entity-name.spidertron-enhancements-dummy-spidertron", {"entity-name." .. spidertron.name}},
      collision_box = nil, --{{-1 * scale, -1 * scale}, {1 * scale, 1 * scale}},
      sticker_box = nil, --{{-1.5 * scale, -1.5 * scale}, {1.5 * scale, 1.5 * scale}},
      selection_box = {{-1 * scale, -1 * scale}, {1 * scale, 1 * scale}},
      drawing_box = {{-3 * scale, -4 * scale}, {3 * scale, 2 * scale}},
      icon = "__base__/graphics/icons/spidertron.png",
      mined_sound = {filename = "__core__/sound/deconstruct-large.ogg",volume = 0.8},
      open_sound = { filename = "__base__/sound/spidertron/spidertron-door-open.ogg", volume= 0.35 },
      close_sound = { filename = "__base__/sound/spidertron/spidertron-door-close.ogg", volume = 0.4 },
      sound_minimum_speed = 0.1,
      sound_scaling_ratio = 0.6,
      working_sound =
      {
        sound =
        {
          filename = "__base__/sound/spidertron/spidertron-vox.ogg",
          volume = 0.35
        },
        activate_sound =
        {
          filename = "__base__/sound/spidertron/spidertron-activate.ogg",
          volume = 0.5
        },
        deactivate_sound =
        {
          filename = "__base__/sound/spidertron/spidertron-deactivate.ogg",
          volume = 0.5
        },
        match_speed_to_activity = true
      },
      icon_size = 64, icon_mipmaps = 4,
      weight = 1,
      braking_force = 1,
      friction_force = 1,
      flags = {"placeable-neutral", "player-creation", "placeable-off-grid"},
      collision_mask = {},
      minable = spidertron.minable,
      max_health = spidertron.max_health,
      resistances = spidertron.resistances,
      minimap_representation = spidertron.minimap_representation,
      corpse = spidertron.corpse,
      dying_explosion = spidertron.dying_explosion,
      energy_per_hit_point = spidertron.energy_per_hit_point,
      guns = spidertron.guns,
      inventory_size = spidertron.inventory_size,
      equipment_grid = spidertron.equipment_grid,
      trash_inventory_size = spidertron.trash_inventory_size,
      height = 1.5  * scale * leg_scale,
      torso_rotation_speed = 0.005,
      chunk_exploration_radius = spidertron.chunk_exploration_radius,
      selection_priority = 51,
      graphics_set = adjust_render_layer(spidertron_torso_graphics_set(scale)),
      energy_source = spidertron.enery_source or {type = "void"},
      movement_energy_consumption = spidertron.movement_energy_consumption,
      automatic_weapon_cycling = spidertron.automatic_weapon_cycling,
      chain_shooting_cooldown_modifier = spidertron.chain_shooting_cooldown_modifier,
      spider_engine =
      {
        legs =
        {
          { -- 1
            leg = name .. "-leg-1",
            mount_position = util.by_pixel(15  * scale, -22 * scale),--{0.5, -0.75},
            ground_position = {2.25  * leg_scale, -2.5  * leg_scale},
            blocking_legs = {2},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          { -- 2
            leg = name .. "-leg-2",
            mount_position = util.by_pixel(23  * scale, -10  * scale),--{0.75, -0.25},
            ground_position = {3  * leg_scale, -1  * leg_scale},
            blocking_legs = {1, 3},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          { -- 3
            leg = name .. "-leg-3",
            mount_position = util.by_pixel(25  * scale, 4  * scale),--{0.75, 0.25},
            ground_position = {3  * leg_scale, 1  * leg_scale},
            blocking_legs = {2, 4},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          { -- 4
            leg = name .. "-leg-4",
            mount_position = util.by_pixel(15  * scale, 17  * scale),--{0.5, 0.75},
            ground_position = {2.25  * leg_scale, 2.5  * leg_scale},
            blocking_legs = {3},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          { -- 5
            leg = name .. "-leg-5",
            mount_position = util.by_pixel(-15 * scale, -22 * scale),--{-0.5, -0.75},
            ground_position = {-2.25 * leg_scale, -2.5 * leg_scale},
            blocking_legs = {6, 1},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          { -- 6
            leg = name .. "-leg-6",
            mount_position = util.by_pixel(-23 * scale, -10 * scale),--{-0.75, -0.25},
            ground_position = {-3 * leg_scale, -1 * leg_scale},
            blocking_legs = {5, 7},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          { -- 7
            leg = name .. "-leg-7",
            mount_position = util.by_pixel(-25 * scale, 4 * scale),--{-0.75, 0.25},
            ground_position = {-3 * leg_scale, 1 * leg_scale},
            blocking_legs = {6, 8},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          { -- 8
            leg = name .. "-leg-8",
            mount_position = util.by_pixel(-15 * scale, 17 * scale),--{-0.5, 0.75},
            ground_position = {-2.25 * leg_scale, 2.5 * leg_scale},
            blocking_legs = {7},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          }
        },
        military_target = "spidertron-military-target"
      }
    },
    remove_hitboxes(make_spidertron_leg(name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 1)),
    remove_hitboxes(make_spidertron_leg(name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 2)),
    remove_hitboxes(make_spidertron_leg(name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 3)),
    remove_hitboxes(make_spidertron_leg(name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 4)),
    remove_hitboxes(make_spidertron_leg(name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 5)),
    remove_hitboxes(make_spidertron_leg(name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 6)),
    remove_hitboxes(make_spidertron_leg(name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 7)),
    remove_hitboxes(make_spidertron_leg(name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 8)),
  })
end


-- Create a dummy spidertron for each spidertron in the game (to allow for modded spidertrons)
local spidertrons = table.deepcopy(data.raw["spider-vehicle"])
for _, spidertron in pairs(spidertrons) do
  create_dummy_spidertron{spidertron = spidertron,
                          scale = 0.8,
                          leg_scale = 0.5,
                          leg_thickness = 1.5,
                          leg_movement_speed = 1,
  }
end
-- leg_scale relative to scale
-- leg_thickness relative to leg_scale
