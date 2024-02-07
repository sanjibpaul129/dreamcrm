json.array!(@designations) do |designation|
  json.extract! designation, :id, :description, :organisation_id
  json.url designation_url(designation, format: :json)
end
