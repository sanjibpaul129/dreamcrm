class AddReadOnToWhatsappFollowup < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_followups, :read_on, :datetime
  end
end
