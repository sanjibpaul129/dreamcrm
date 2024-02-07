class Changefieldwoitem < ActiveRecord::Migration[5.2]
  def change
  	remove_column :marketing_instances, :work_order_id, :integer
  	remove_column :marketing_instances, :rate, :decimal
  	remove_column :marketing_instances, :quantity, :decimal
  	remove_column :marketing_instances, :tax, :decimal
  	remove_column :bill_items, :marketing_instance_id, :integer
  	add_column :bill_items, :work_order_item_id, :integer
  end
end
