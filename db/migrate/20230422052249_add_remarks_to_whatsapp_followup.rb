class AddRemarksToWhatsappFollowup < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_followups, :remarks, :text
  end
end
