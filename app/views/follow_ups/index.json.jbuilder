json.array!(@follow_ups) do |follow_up|
  json.extract! follow_up, :id, :lead_id, :remarks, :communication_time, :follow_up_time, :personnel_id, :status, :business_unit_id, :escalated, :hot
  json.url follow_up_url(follow_up, format: :json)
end
