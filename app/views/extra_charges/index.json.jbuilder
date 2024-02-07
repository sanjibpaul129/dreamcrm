json.array!(@extra_charges) do |extra_charge|
  json.extract! extra_charge, :id, :organisation_id, :description, :service_tax
  json.url extra_charge_url(extra_charge, format: :json)
end
