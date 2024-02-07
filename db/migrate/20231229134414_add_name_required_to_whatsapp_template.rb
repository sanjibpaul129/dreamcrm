class AddNameRequiredToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :name_required, :boolean
  end
end
