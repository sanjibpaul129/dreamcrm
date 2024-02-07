class AddDeliveredOnToWhatsappFollowup < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_followups, :delivered_on, :datetime
  end
end
