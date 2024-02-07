json.array!(@stations) do |station|
  json.extract! station, :id, :description, :organisation_id
  json.url station_url(station, format: :json)
end
