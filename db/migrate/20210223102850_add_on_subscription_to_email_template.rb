class AddOnSubscriptionToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :on_subscription, :boolean
  end
end
