class AddLiveToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :live, :boolean
  end
end
