class RemoveDeliveredFromWhatsappFollowup < ActiveRecord::Migration[5.2]
  def change
    remove_column :whatsapp_followups, :delivered, :boolean
  end
end
