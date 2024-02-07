class AddBrokerContactIdToWhatsappFollowup < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_followups, :broker_contact_id, :integer
  end
end
