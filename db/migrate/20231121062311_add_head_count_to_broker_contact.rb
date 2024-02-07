class AddHeadCountToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :head_count, :integer
  end
end
