json.array!(@project_rates) do |project_rate|
  json.extract! project_rate, :id, :business_unit_id, :base_rate, :date
  json.url project_rate_url(project_rate, format: :json)
end
