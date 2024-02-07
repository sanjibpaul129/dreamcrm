class AddSourceByCustomerToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :source_by_customer, :text
  end
end
