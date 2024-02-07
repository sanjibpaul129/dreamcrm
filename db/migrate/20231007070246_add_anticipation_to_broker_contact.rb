class AddAnticipationToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :anticipation, :boolean
  end
end
