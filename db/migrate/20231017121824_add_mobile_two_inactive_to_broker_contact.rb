class AddMobileTwoInactiveToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :mobile_two_inactive, :boolean
  end
end
