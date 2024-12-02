---@diagnostic disable: undefined-field
for i, serialised_data in pairs(storage.stored_spidertrons_personal) do
  serialised_data.quality = serialised_data.quality.name
  if serialised_data.equipment then
    for _, equipment in pairs(serialised_data.equipment) do
      if equipment.quality then
        equipment.quality = equipment.quality.name
      end
    end
  end
end
for i, serialised_data in pairs(storage.stored_spidertrons) do
  serialised_data.quality = serialised_data.quality.name
  if serialised_data.equipment then
    for _, equipment in pairs(serialised_data.equipment) do
      if equipment.quality then
        equipment.quality = equipment.quality.name
      end
    end
  end
end
