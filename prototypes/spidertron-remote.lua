local temporary_remote = table.deepcopy(data.raw["spidertron-remote"]["spidertron-remote"])

temporary_remote.name = "spidertron-enhancements-temporary-spidertron-remote"

local flags = temporary_remote.flags

if flags then
  temporary_remote.flags.insert("hidden")
  temporary_remote.flags.insert("only-in-cursor")
else
  temporary_remote.flags = {"hidden", "only-in-cursor"}
end

data:extend{temporary_remote}