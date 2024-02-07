class AddMailedOnToMoneyReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :money_receipts, :mailed_on, :datetime
  end
end
