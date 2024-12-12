local simulations = require("__SpidertronEnhancements__/prototypes/tips-and-tricks-simulations")
if mods["SpidertronEngineer"] then return end

data:extend{
  {
    type = "tips-and-tricks-item-category",
    name = "spidertron-enhancements",
    order = "-a[spidertron-enhancements]"
  },
  {
    type = "tips-and-tricks-item",
    name = "spidertron-enhancements",
    tag = "[entity=spidertron]",
    category = "spidertron-enhancements",
    is_title = true,
    order = "a",
    trigger = {type = "build-entity", entity = "spidertron", match_type_only = true}
  },
  {
    type = "tips-and-tricks-item",
    name = "spidertron-enhancements-enter-train",
    tag = "[entity=spidertron][entity=locomotive][entity=car]",
    category = "spidertron-enhancements",
    indent = 1,
    order = "b",
    trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
    simulation = simulations.enter_train
  },
  {
    type = "tips-and-tricks-item",
    name = "spidertron-enhancements-quick-toggle",
    tag = "[entity=spidertron][entity=character]",
    category = "spidertron-enhancements",
    indent = 1,
    order = "c",
    trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
    simulation = simulations.quick_toggle
  },
  {
    type = "tips-and-tricks-item",
    name = "spidertron-enhancements-pathfinder",
    tag = "[item=spidertron-remote]",
    category = "spidertron-enhancements",
    indent = 1,
    order = "d",
    trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
    simulation = simulations.pathfinder
  },
  {
    type = "tips-and-tricks-item",
    name = "spidertron-enhancements-remote-pipette",
    tag = "[item=spidertron-remote]",
    category = "spidertron-enhancements",
    indent = 1,
    order = "e",
    trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
    simulation = simulations.remote_pipette
  },
}
