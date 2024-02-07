class AddGroundFloorBuiltUpToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :ground_floor_built_up, :decimal
  end
end
