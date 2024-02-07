class RemoveCallAttemptedFromBrokerContact < ActiveRecord::Migration[5.2]
  def change
    remove_column :broker_contacts, :call_attempted, :boolean
  end
end
