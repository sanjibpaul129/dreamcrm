class AddPersonnelIdToMoneyReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :money_receipts, :personnel_id, :integer
  end
end
