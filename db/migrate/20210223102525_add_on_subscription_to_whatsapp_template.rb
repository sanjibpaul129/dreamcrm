class AddOnSubscriptionToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :on_subscription, :boolean
  end
end
