class CreateBillItems < ActiveRecord::Migration[5.2]
  def change
    create_table :bill_items do |t|
      t.integer :marketing_instance_id
      t.datetime :from
      t.datetime :to
      t.decimal :quantity
      t.boolean :status
      t.string :remarks
      t.integer :bill_id

      t.timestamps
    end
  end
end
