class AddDeliveredToWhatsappFollowup < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_followups, :delivered, :boolean
  end
end
