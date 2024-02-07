class AddReadToBulkRecipient < ActiveRecord::Migration[5.2]
  def change
    add_column :bulk_recipients, :read, :boolean
  end
end
