class AddCallAttemptedToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :call_attempted, :boolean
  end
end
