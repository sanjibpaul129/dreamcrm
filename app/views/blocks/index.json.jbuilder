json.array!(@blocks) do |block|
  json.extract! block, :id, :business_unit_id, :name, :number, :floors
  json.url block_url(block, format: :json)
end
