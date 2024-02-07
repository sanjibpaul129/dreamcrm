json.array!(@plcs) do |plc|
  json.extract! plc, :id, :name, :organisation_id
  json.url plc_url(plc, format: :json)
end
