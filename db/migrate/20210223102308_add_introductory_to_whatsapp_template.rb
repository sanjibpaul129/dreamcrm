class AddIntroductoryToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :introductory, :boolean
  end
end
