class RemovePersonnelIdFromBroker < ActiveRecord::Migration[5.2]
  def change
    remove_column :brokers, :personnel_id, :integer
  end
end
