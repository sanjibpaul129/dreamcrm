class AddFlatIdToMoneyReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :money_receipts, :flat_id, :integer
  end
end
