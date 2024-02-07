class RemoveCallConnectedFromBrokerContact < ActiveRecord::Migration[5.2]
  def change
    remove_column :broker_contacts, :call_connected, :boolean
  end
end
