json.array!(@flats) do |flat|
  json.extract! flat, :id, :block_id, :floor, :name, :status, :SBA, :OTA, :flat_bua, :ot_bua, :flat_bua_markup, :ot_bua_markdown, :bathrooms, :balconies
  json.url flat_url(flat, format: :json)
end
