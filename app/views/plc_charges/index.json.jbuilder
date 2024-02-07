json.array!(@plc_charges) do |plc_charge|
  json.extract! plc_charge, :id, :block_id, :plc_id, :rate
  json.url plc_charge_url(plc_charge, format: :json)
end
