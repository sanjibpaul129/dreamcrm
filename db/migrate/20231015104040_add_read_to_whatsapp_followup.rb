class AddReadToWhatsappFollowup < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_followups, :Read, :boolean
  end
end
