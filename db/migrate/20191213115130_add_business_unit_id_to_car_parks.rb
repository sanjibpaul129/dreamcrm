class AddBusinessUnitIdToCarParks < ActiveRecord::Migration[5.2]
  def change
    add_column :car_parks, :business_unit_id, :integer
  end
end
