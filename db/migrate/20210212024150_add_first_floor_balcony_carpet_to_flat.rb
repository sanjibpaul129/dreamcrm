class AddFirstFloorBalconyCarpetToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :first_floor_balcony_carpet, :decimal
  end
end
