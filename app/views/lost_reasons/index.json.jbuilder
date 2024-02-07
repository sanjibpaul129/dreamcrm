json.array!(@lost_reasons) do |lost_reason|
  json.extract! lost_reason, :id, :description, :organisation_id
  json.url lost_reason_url(lost_reason, format: :json)
end
