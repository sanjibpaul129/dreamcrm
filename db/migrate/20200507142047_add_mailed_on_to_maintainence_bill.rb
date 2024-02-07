class AddMailedOnToMaintainenceBill < ActiveRecord::Migration[5.2]
  def change
    add_column :maintainence_bills, :mailed_on, :datetime
  end
end
