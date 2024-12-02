for i, serialised_data in pairs(storage.stored_spidertrons_personal) do
  serialised_data.quality = serialised_data.quality.name
end
for i, serialised_data in pairs(storage.stored_spidertrons) do
  serialised_data.quality = serialised_data.quality.name
end
