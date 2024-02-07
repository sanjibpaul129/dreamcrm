class AddAdHocToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :ad_hoc, :boolean
  end
end
