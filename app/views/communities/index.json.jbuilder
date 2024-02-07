json.array!(@communities) do |community|
  json.extract! community, :id, :description, :organisation_id
  json.url community_url(community, format: :json)
end
