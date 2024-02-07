class RemoveTemplateTypeFromWhatsappFollowup < ActiveRecord::Migration[5.2]
  def change
    remove_column :whatsapp_followups, :template_type, :string
  end
end
