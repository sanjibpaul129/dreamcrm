class AddCarpetAreaToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :carpet_area, :integer
  end
end
