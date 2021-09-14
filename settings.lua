data:extend({
    {
        type = "bool-setting",
        name = "spidertron-enhancements-enter-entity-base-game",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "aa"
    },
    {
        type = "bool-setting",
        name = "spidertron-enhancements-enter-entity-custom",
        setting_type = "runtime-per-user",
        default_value = false,
        order = "ab"
    },
    {
        type = "bool-setting",
        name = "spidertron-enhancements-pipette-unconnected-remote",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "b"
    },
    {
        type = "string-setting",
        name = "spidertron-enhancements-enter-entity",
        setting_type = "runtime-global",
        default_value = "all-except-spidertrons",
        allowed_values = {"none", "trains", "all-except-spidertrons", "all"},
        order = "aa"
    },
    {
        type = "bool-setting",
        name = "spidertron-enhancements-show-spider-on-vehicle",
        setting_type = "runtime-global",
        default_value = true,
        order = "ab"
    },
    {
        type = "bool-setting",
        name = "spidertron-enhancements-enter-player",
        setting_type = "runtime-global",
        default_value = true,
        order = "b"
    },
    {
        type = "bool-setting",
        name = "spidertron-enhancements-auto-sort-inventory",
        setting_type = "runtime-global",
        default_value = true,
        order = "c"
    },
    {
        type = "bool-setting",
        name = "spidertron-enhancements-pipette-temporary-remote",
        setting_type = "runtime-global",
        default_value = false,
        order = "d"
    },
    {
        type = "bool-setting",
        name = "spidertron-enhancements-enable-corpse",
        setting_type = "startup",
        default_value = true,
        order = "a"
    },
    {
        type = "double-setting",
        name = "spidertron-enhancements-sound-pause",
        setting_type = "startup",
        default_value = 0,
        minimum_value = 0,
        order = "b",
    },
    {
        type = "double-setting",
        name = "spidertron-enhancements-volume-scale",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 0,
        order = "c",
    }
})

if mods["SpidertronEngineer"] then
    -- Disable Spidertron Enhancement features that aren't compatible
    data.raw["bool-setting"]["spidertron-enhancements-enter-entity-base-game"].hidden = true
    data.raw["bool-setting"]["spidertron-enhancements-enter-entity-custom"].hidden = true
    data.raw["string-setting"]["spidertron-enhancements-enter-entity"].hidden = true
    data.raw["bool-setting"]["spidertron-enhancements-show-spider-on-vehicle"].hidden = true
    data.raw["bool-setting"]["spidertron-enhancements-enter-player"].hidden = true

    data.raw["bool-setting"]["spidertron-enhancements-enter-entity-base-game"].forced_value = false
    data.raw["bool-setting"]["spidertron-enhancements-enter-entity-custom"].forced_value = false
    data.raw["string-setting"]["spidertron-enhancements-enter-entity"].forced_value = false
    data.raw["bool-setting"]["spidertron-enhancements-show-spider-on-vehicle"].forced_value = false
    data.raw["bool-setting"]["spidertron-enhancements-enter-player"].forced_value = false
end