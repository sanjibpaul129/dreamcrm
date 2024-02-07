class AddCancelledOnToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :cancelled_on, :datetime
  end
end
