class AddQualifiedToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :qualified, :boolean
  end
end
