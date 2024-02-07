json.array!(@bills) do |bill|
  json.extract! bill, :id, :number, :date, :remarks, :status
  json.url bill_url(bill, format: :json)
end
