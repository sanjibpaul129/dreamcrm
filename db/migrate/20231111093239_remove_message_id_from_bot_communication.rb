class RemoveMessageIdFromBotCommunication < ActiveRecord::Migration[5.2]
  def change
    remove_column :bot_communications, :message_id, :string
  end
end
