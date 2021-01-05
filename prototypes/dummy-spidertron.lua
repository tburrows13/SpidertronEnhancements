require "__base__/prototypes/entity/spidertron-animations"

local function remove_hitboxes(spidertron_leg)
  spidertron_leg.collision_box = nil
  spidertron_leg.selection_box = nil
  spidertron_leg.collision_mask = {}
  return spidertron_leg
end


local function create_spidertron(arguments)
  local scale = arguments.scale
  local leg_scale = scale * arguments.leg_scale
  data:extend(
  {
    {
      type = "spider-vehicle",
      name = arguments.name,
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
      minable = {mining_time = 1, result = "spidertron"},
      max_health = 3000,
      resistances =
      {
        {
          type = "fire",
          decrease = 15,
          percent = 60
        },
        {
          type = "physical",
          decrease = 15,
          percent = 60
        },
        {
          type = "impact",
          decrease = 50,
          percent = 80
        },
        {
          type = "explosion",
          decrease = 20,
          percent = 75
        },
        {
          type = "acid",
          decrease = 0,
          percent = 70
        },
        {
          type = "laser",
          decrease = 0,
          percent = 70
        },
        {
          type = "electric",
          decrease = 0,
          percent = 70
        }
      },
      minimap_representation =
      {
        filename = "__base__/graphics/entity/spidertron/spidertron-map.png",
        flags = {"icon"},
        size = {128, 128},
        scale = 0.5
      },
      corpse = "spidertron-remnants",
      dying_explosion = "spidertron-explosion",
      energy_per_hit_point = 1,
      guns = { "spidertron-rocket-launcher-1", "spidertron-rocket-launcher-2", "spidertron-rocket-launcher-3", "spidertron-rocket-launcher-4" },
      inventory_size = 80,
      equipment_grid = "spidertron-equipment-grid",
      trash_inventory_size = 20,
      height = 1.5  * scale * leg_scale,
      torso_rotation_speed = 0.005,
      chunk_exploration_radius = 3,
      selection_priority = 51,
      graphics_set = spidertron_torso_graphics_set(scale),
      energy_source =
      {
        type = "void"
      },
      movement_energy_consumption = "250kW",
      automatic_weapon_cycling = true,
      chain_shooting_cooldown_modifier = 0.5,
      spider_engine =
      {
        legs =
        {
          { -- 1
            leg = arguments.name .. "-leg-1",
            mount_position = util.by_pixel(15  * scale, -22 * scale),--{0.5, -0.75},
            ground_position = {2.25  * leg_scale, -2.5  * leg_scale},
            blocking_legs = {2},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          { -- 2
            leg = arguments.name .. "-leg-2",
            mount_position = util.by_pixel(23  * scale, -10  * scale),--{0.75, -0.25},
            ground_position = {3  * leg_scale, -1  * leg_scale},
            blocking_legs = {1, 3},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          { -- 3
            leg = arguments.name .. "-leg-3",
            mount_position = util.by_pixel(25  * scale, 4  * scale),--{0.75, 0.25},
            ground_position = {3  * leg_scale, 1  * leg_scale},
            blocking_legs = {2, 4},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          { -- 4
            leg = arguments.name .. "-leg-4",
            mount_position = util.by_pixel(15  * scale, 17  * scale),--{0.5, 0.75},
            ground_position = {2.25  * leg_scale, 2.5  * leg_scale},
            blocking_legs = {3},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          { -- 5
            leg = arguments.name .. "-leg-5",
            mount_position = util.by_pixel(-15 * scale, -22 * scale),--{-0.5, -0.75},
            ground_position = {-2.25 * leg_scale, -2.5 * leg_scale},
            blocking_legs = {6, 1},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          { -- 6
            leg = arguments.name .. "-leg-6",
            mount_position = util.by_pixel(-23 * scale, -10 * scale),--{-0.75, -0.25},
            ground_position = {-3 * leg_scale, -1 * leg_scale},
            blocking_legs = {5, 7},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          { -- 7
            leg = arguments.name .. "-leg-7",
            mount_position = util.by_pixel(-25 * scale, 4 * scale),--{-0.75, 0.25},
            ground_position = {-3 * leg_scale, 1 * leg_scale},
            blocking_legs = {6, 8},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          { -- 8
            leg = arguments.name .. "-leg-8",
            mount_position = util.by_pixel(-15 * scale, 17 * scale),--{-0.5, 0.75},
            ground_position = {-2.25 * leg_scale, 2.5 * leg_scale},
            blocking_legs = {7},
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          }
        },
        military_target = "spidertron-military-target"
      }
    },
    remove_hitboxes(make_spidertron_leg(arguments.name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 1)),
    remove_hitboxes(make_spidertron_leg(arguments.name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 2)),
    remove_hitboxes(make_spidertron_leg(arguments.name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 3)),
    remove_hitboxes(make_spidertron_leg(arguments.name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 4)),
    remove_hitboxes(make_spidertron_leg(arguments.name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 5)),
    remove_hitboxes(make_spidertron_leg(arguments.name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 6)),
    remove_hitboxes(make_spidertron_leg(arguments.name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 7)),
    remove_hitboxes(make_spidertron_leg(arguments.name, leg_scale, arguments.leg_thickness, arguments.leg_movement_speed, 8)),
  })
end

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

create_spidertron{name = "spidertron-enhancements-dummy-spidertron", scale = 0.8, leg_scale = 0.5, leg_thickness = 1.5, leg_movement_speed = 1}
-- leg_scale relative to scale
-- leg_thickness relative to leg_scale
