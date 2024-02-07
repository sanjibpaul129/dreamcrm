json.array!(@newspapers) do |newspaper|
  json.extract! newspaper, :id, :description, :organisation_id
  json.url newspaper_url(newspaper, format: :json)
end
