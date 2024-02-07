class Addflatypetoleads < ActiveRecord::Migration[5.2]
  def change
  	add_column :leads, :flat_type, :integer
  	add_column :source_categories, :heirarchy, :string
  end
end
