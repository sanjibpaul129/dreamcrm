class AddManuallyMailedOnToMoneyReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :money_receipts, :manually_mailed_on, :datetime
  end
end
