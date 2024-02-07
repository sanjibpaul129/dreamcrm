class AddMobileOneInactiveToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :mobile_one_inactive, :boolean
  end
end
