class AddBankNameToMoneyReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :money_receipts, :bank_name, :string
  end
end
