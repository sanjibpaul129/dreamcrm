class RemoveNumberOfCarParkingFromCostSheet < ActiveRecord::Migration[5.2]
  def change
    remove_column :cost_sheets, :number_of_car_parkings, :integer
  end
end
