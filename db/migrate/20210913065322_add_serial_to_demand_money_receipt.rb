class AddSerialToDemandMoneyReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :demand_money_receipts, :serial, :integer
  end
end
