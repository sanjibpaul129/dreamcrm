json.array!(@business_units) do |business_unit|
  json.extract! business_unit, :id, :name, :organisation_id, :company_id, :address_1, :address_2, :address_3, :address_4, :email, :shortform, :logo
  json.url business_unit_url(business_unit, format: :json)
end
