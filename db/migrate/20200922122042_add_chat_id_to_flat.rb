class AddChatIdToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :chat_id, :integer
  end
end
