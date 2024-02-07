class AddInactiveToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :inactive, :boolean
  end
end
