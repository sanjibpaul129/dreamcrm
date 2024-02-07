json.array!(@companies) do |company|
  json.extract! company, :id, :name, :organisation_id, :address_1, :address_2, :address_3, :address_4, :phone
  json.url company_url(company, format: :json)
end
