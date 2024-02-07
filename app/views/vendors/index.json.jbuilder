json.array!(@vendors) do |vendor|
  json.extract! vendor, :id, :name, :email, :mobile, :organisation_id
  json.url vendor_url(vendor, format: :json)
end
