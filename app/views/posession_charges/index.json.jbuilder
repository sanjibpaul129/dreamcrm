json.array!(@posession_charges) do |posession_charge|
  json.extract! posession_charge, :id, :block_id, :extra_charge_id, :amount, :rate
  json.url posession_charge_url(posession_charge, format: :json)
end
