json.array!(@flc_charges) do |flc_charge|
  json.extract! flc_charge, :id, :block_id, :rate, :from_floor
  json.url flc_charge_url(flc_charge, format: :json)
end
