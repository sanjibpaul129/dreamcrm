class RenameNatureIdToCarParkNatureIdInCarPark < ActiveRecord::Migration[5.2]
  def change
  	rename_column :car_parks, :nature_id, :car_park_nature_id
  end
end
