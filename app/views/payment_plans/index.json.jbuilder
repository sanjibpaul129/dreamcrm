json.array!(@payment_plans) do |payment_plan|
  json.extract! payment_plan, :id, :block_id, :description, :business_unit_id
  json.url payment_plan_url(payment_plan, format: :json)
end
