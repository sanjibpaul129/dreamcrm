class AddWhatsappKeyToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :whatsapp_key, :string
  end
end
