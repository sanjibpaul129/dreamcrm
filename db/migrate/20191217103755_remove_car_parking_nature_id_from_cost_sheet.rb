class RemoveCarParkingNatureIdFromCostSheet < ActiveRecord::Migration[5.2]
  def change
    remove_column :cost_sheets, :car_parking_nature_id, :integer
  end
end
