class AddLandAreaToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :land_area, :decimal
  end
end
