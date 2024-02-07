class AddToSendToBulkRecipient < ActiveRecord::Migration[5.2]
  def change
    add_column :bulk_recipients, :to_send, :boolean
  end
end
