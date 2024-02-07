class AddManuallyMailedOnToMaintainenceBill < ActiveRecord::Migration[5.2]
  def change
    add_column :maintainence_bills, :manually_mailed_on, :datetime
  end
end
