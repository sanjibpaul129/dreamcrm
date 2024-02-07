json.array!(@work_order_items) do |work_order_item|
  json.extract! work_order_item, :id, :marketing_instance_id, :work_order_id, :rate, :quantity, :tax, :remarks
  json.url work_order_item_url(work_order_item, format: :json)
end
