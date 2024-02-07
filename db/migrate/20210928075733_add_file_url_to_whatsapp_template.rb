class AddFileUrlToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :file_url, :text
  end
end
