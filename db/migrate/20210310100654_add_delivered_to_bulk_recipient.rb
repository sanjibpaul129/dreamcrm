class AddDeliveredToBulkRecipient < ActiveRecord::Migration[5.2]
  def change
    add_column :bulk_recipients, :delivered, :boolean
  end
end
