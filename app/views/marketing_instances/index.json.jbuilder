json.array!(@marketing_instances) do |marketing_instance|
  json.extract! marketing_instance, :id, :description, :business_unit_id, :source_category_id, :work_order_id, :rate, :quantity, :tax
  json.url marketing_instance_url(marketing_instance, format: :json)
end
