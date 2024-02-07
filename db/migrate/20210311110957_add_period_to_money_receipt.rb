class AddPeriodToMoneyReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :money_receipts, :period, :text
  end
end
