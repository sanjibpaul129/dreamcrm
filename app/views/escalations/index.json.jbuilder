json.array!(@escalations) do |escalation|
  json.extract! escalation, :id, :level, :personnel_id, :year, :month, :count
  json.url escalation_url(escalation, format: :json)
end
