class AddFirstFloorCarpetAreaToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :first_floor_carpet, :decimal
  end
end
