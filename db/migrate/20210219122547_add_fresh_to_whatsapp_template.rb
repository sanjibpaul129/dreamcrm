class AddFreshToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :fresh, :boolean
  end
end
