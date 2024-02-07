class AddPincodeToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :pincode, :string
  end
end
