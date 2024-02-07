class AddLastToMoneyReceiptSerial < ActiveRecord::Migration[5.2]
  def change
    add_column :money_receipt_serials, :last, :integer
  end
end
