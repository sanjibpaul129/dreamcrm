class AddRateToElectricalBill < ActiveRecord::Migration[5.2]
  def change
    add_column :electrical_bills, :rate, :decimal
  end
end
