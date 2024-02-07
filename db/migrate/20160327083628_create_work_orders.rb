class CreateWorkOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :work_orders do |t|
      t.integer :vendor_id
      t.datetime :date
      t.integer :company_id

      t.timestamps
    end
  end
end
