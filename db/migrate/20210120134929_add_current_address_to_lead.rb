class AddCurrentAddressToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :current_address, :text
  end
end
