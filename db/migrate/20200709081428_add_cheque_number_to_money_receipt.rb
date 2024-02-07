class AddChequeNumberToMoneyReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :money_receipts, :cheque_number, :string
  end
end
