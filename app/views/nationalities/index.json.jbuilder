json.array!(@nationalities) do |nationality|
  json.extract! nationality, :id, :description, :organisation_id
  json.url nationality_url(nationality, format: :json)
end
