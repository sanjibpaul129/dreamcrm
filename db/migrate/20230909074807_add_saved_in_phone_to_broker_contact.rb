class AddSavedInPhoneToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :saved_in_phone, :boolean
  end
end
