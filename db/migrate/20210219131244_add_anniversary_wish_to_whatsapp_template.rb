class AddAnniversaryWishToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :anniversary_wish, :boolean
  end
end
