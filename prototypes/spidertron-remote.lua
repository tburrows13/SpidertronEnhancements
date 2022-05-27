local function generate_temporary_remote(remote_name)
  local remote = data.raw["spidertron-remote"][remote_name]
  if remote then
    local temporary_remote = table.deepcopy(remote)

    temporary_remote.name = "spidertron-enhancements-temporary-" .. remote_name
    temporary_remote.localised_name = remote.localised_name or {"item-name." .. remote_name}
    temporary_remote.order = remote.order .. "z"

    local flags = temporary_remote.flags
    if flags then
      temporary_remote.flags.insert("hidden")
      temporary_remote.flags.insert("only-in-cursor")
    else
      temporary_remote.flags = {"hidden", "only-in-cursor"}
    end

    data:extend{temporary_remote}
  end
end

generate_temporary_remote("spidertron-remote")
generate_temporary_remote("sp-spidertron-patrol-remote")
