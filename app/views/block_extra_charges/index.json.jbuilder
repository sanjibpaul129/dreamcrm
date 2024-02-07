json.array!(@block_extra_charges) do |block_extra_charge|
  json.extract! block_extra_charge, :id, :block_id, :extra_charge_id, :percentage, :amount, :rate, :flat_type
  json.url block_extra_charge_url(block_extra_charge, format: :json)
end
