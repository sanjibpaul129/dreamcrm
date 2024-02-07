class AddPersonnelIdToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :personnel_id, :integer
  end
end
