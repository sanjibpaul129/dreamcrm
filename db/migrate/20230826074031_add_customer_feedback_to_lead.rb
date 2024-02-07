class AddCustomerFeedbackToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :customer_feedback, :text
  end
end
