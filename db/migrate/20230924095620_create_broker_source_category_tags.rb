class CreateBrokerSourceCategoryTags < ActiveRecord::Migration[5.2]
  def change
    create_table :broker_source_category_tags do |t|
      t.integer :broker_id
      t.integer :source_category_id

      t.timestamps null: false
    end
  end
end
