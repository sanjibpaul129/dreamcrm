class AddAttemptedCallToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :call_attempted, :integer
  end
end
