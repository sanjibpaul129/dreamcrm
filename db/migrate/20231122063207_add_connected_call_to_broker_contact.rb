class AddConnectedCallToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :call_connected, :integer
  end
end
