class AddGroundFloorCarpetToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :ground_floor_carpet, :decimal
  end
end
