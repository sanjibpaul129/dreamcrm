class AddSecondFloorCarpetToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :second_floor_carpet, :decimal
  end
end
