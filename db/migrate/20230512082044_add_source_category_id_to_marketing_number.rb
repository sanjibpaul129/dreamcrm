class AddSourceCategoryIdToMarketingNumber < ActiveRecord::Migration[5.2]
  def change
    add_column :marketing_numbers, :source_category_id, :integer
  end
end
