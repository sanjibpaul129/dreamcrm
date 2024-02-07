class AddOpeningReadingToElectricalMoneyReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :electrical_money_receipts, :opening_reading, :decimal
  end
end
