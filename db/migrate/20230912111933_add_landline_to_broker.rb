class AddLandlineToBroker < ActiveRecord::Migration[5.2]
  def change
    add_column :brokers, :landline, :string
  end
end
