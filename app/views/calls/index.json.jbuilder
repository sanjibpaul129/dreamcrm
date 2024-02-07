json.array!(@calls) do |call|
  json.extract! call, :id, :marketing_number_id, :number_id, :number, :start_time, :end_time, :personnels_id, :nature
  json.url call_url(call, format: :json)
end
