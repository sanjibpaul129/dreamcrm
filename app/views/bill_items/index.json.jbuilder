json.array!(@bill_items) do |bill_item|
  json.extract! bill_item, :id, :marketing_instance_id, :from, :to, :quantity, :status, :remarks, :bill_id
  json.url bill_item_url(bill_item, format: :json)
end
