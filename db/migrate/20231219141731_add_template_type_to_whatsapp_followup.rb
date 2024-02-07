class AddTemplateTypeToWhatsappFollowup < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_followups, :template_type, :string
  end
end
