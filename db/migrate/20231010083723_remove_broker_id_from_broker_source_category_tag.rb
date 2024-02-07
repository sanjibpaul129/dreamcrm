class RemoveBrokerIdFromBrokerSourceCategoryTag < ActiveRecord::Migration[5.2]
  def change
    remove_column :broker_source_category_tags, :broker_id, :integer
  end
end
