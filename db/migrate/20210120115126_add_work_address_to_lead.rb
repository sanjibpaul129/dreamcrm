class AddWorkAddressToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :work_address, :text
  end
end
