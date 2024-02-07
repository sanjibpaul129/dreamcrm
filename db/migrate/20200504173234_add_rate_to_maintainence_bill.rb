class AddRateToMaintainenceBill < ActiveRecord::Migration[5.2]
  def change
    add_column :maintainence_bills, :rate, :decimal
  end
end
