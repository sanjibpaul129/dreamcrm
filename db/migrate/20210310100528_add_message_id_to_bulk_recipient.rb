class AddMessageIdToBulkRecipient < ActiveRecord::Migration[5.2]
  def change
    add_column :bulk_recipients, :message_id, :integer
  end
end
