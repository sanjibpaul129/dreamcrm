class AddBirthdayWishToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :birthday_wish, :boolean
  end
end
