class AddFlatIdToMaintainenceBill < ActiveRecord::Migration[5.2]
  def change
    add_column :maintainence_bills, :flat_id, :integer
  end
end
