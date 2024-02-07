class CreateWorkOrderItems < ActiveRecord::Migration[5.2]
  def change
    create_table :work_order_items do |t|
      t.integer :marketing_instance_id
      t.integer :work_order_id
      t.decimal :rate
      t.decimal :quantity
      t.decimal :tax
      t.string :remarks

      t.timestamps
    end
  end
end
