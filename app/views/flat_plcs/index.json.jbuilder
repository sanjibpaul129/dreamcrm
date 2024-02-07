json.array!(@flat_plcs) do |flat_plc|
  json.extract! flat_plc, :id, :flat_id, :plc_charge_id
  json.url flat_plc_url(flat_plc, format: :json)
end
