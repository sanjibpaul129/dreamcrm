class AddSecondFloorBuiltUpToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :second_floor_built_up, :decimal
  end
end
