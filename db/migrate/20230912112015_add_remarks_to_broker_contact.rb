class AddRemarksToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :remarks, :text
  end
end
