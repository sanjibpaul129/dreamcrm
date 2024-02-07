class AddInactiveToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :inactive, :boolean
  end
end
