class AddAmountToMaintainenceBill < ActiveRecord::Migration[5.2]
  def change
    add_column :maintainence_bills, :amount, :decimal
  end
end
