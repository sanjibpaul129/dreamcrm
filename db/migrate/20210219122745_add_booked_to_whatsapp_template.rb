class AddBookedToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :Booked, :boolean
  end
end
