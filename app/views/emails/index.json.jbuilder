json.array!(@emails) do |email|
  json.extract! email, :id, :subject, :organisation_id, :body, :lead_id, :date, :from
  json.url email_url(email, format: :json)
end
