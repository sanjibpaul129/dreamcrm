class AddReferenceToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :reference, :string
  end
end
