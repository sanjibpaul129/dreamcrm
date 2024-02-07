json.array!(@preferred_locations) do |preferred_location|
  json.extract! preferred_location, :id, :description, :organisation_id
  json.url preferred_location_url(preferred_location, format: :json)
end
