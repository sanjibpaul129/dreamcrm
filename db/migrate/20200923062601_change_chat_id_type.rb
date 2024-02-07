class ChangeChatIdType < ActiveRecord::Migration[5.2]
  def change
  	  change_column :flats, :chat_id, :string
  end
end
