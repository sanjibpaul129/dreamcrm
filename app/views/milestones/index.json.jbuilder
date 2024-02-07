json.array!(@milestones) do |milestone|
  json.extract! milestone, :id, :name, :flat_value_percentage, :extra_charge_percentage, :extra_charge_id, :nature, :payment_plan_id
  json.url milestone_url(milestone, format: :json)
end
