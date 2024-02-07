json.array!(@source_categories) do |source_category|
  json.extract! source_category, :id, :description, :organisation_id, :predecessor
  json.url source_category_url(source_category, format: :json)
end
