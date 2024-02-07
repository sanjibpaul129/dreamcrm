class AddRemarksToMoneyReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :money_receipts, :remarks, :text
  end
end
