class AddClosingReadingToElectricalMoneyReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :electrical_money_receipts, :closing_reading, :decimal
  end
end
