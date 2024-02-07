class AddOfficePincodeToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :office_pincode, :string
  end
end
