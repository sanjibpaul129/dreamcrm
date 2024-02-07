json.array!(@occupations) do |occupation|
  json.extract! occupation, :id, :description, :organisation_id
  json.url occupation_url(occupation, format: :json)
end
