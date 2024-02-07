class AddWhatsappInstanceToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :whatsapp_instance, :string
  end
end
