class AddWhatsappNumberToWhatsappFollowup < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_followups, :whatsapp_number, :string
  end
end
