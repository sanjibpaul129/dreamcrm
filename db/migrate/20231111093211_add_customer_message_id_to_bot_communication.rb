class AddCustomerMessageIdToBotCommunication < ActiveRecord::Migration[5.2]
  def change
    add_column :bot_communications, :customer_message_id, :string
  end
end
