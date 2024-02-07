class RemoveReadFromWhatsappFollowup < ActiveRecord::Migration[5.2]
  def change
    remove_column :whatsapp_followups, :Read, :boolean
  end
end
