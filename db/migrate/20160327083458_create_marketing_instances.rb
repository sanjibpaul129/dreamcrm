class CreateMarketingInstances < ActiveRecord::Migration[5.2]
  def change
    create_table :marketing_instances do |t|
      t.string :description
      t.integer :business_unit_id
      t.integer :source_category_id
      t.integer :work_order_id
      t.decimal :rate
      t.decimal :quantity
      t.decimal :tax

      t.timestamps
    end
  end
end
