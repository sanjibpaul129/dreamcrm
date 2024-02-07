class AddTemplateTypeToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :template_type, :string
  end
end
