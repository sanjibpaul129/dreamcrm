class AddBranchAddressToBusinessUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :business_units, :branch_address, :text
  end
end
