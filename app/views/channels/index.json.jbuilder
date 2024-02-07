json.array!(@channels) do |channel|
  json.extract! channel, :id, :description, :organisation_id
  json.url channel_url(channel, format: :json)
end
