class AddSentToBulkRecipient < ActiveRecord::Migration[5.2]
  def change
    add_column :bulk_recipients, :sent, :boolean
  end
end
