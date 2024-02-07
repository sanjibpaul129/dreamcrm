class AddBotMessageToWhatsappFollowup < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_followups, :bot_message, :text
  end
end
