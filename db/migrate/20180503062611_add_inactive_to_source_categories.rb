class AddInactiveToSourceCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :source_categories, :inactive, :boolean
  end
end
