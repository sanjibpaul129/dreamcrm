class AddChatIdToWishToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :wish_to_customers, :chat_id, :string
  end
end
