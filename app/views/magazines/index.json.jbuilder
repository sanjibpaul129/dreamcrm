json.array!(@magazines) do |magazine|
  json.extract! magazine, :id, :description, :organisation_id
  json.url magazine_url(magazine, format: :json)
end
