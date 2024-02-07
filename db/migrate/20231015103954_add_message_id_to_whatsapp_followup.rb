class AddMessageIdToWhatsappFollowup < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_followups, :message_id, :string
  end
end
