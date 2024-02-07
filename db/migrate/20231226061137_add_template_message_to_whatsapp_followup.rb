class AddTemplateMessageToWhatsappFollowup < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_followups, :template_message, :string
  end
end
