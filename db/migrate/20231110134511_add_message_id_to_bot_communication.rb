class AddMessageIdToBotCommunication < ActiveRecord::Migration[5.2]
  def change
    add_column :bot_communications, :message_id, :string
  end
end
