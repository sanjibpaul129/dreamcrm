class AddFirstFloorBalconyBuiltUpToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :first_floor_balcony_built_up, :decimal
  end
end
