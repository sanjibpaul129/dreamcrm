json.array!(@marketing_numbers) do |marketing_number|
  json.extract! marketing_number, :id, :number, :organisation_id
  json.url marketing_number_url(marketing_number, format: :json)
end
