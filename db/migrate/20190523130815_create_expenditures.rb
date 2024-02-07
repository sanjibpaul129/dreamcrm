class CreateExpenditures < ActiveRecord::Migration[5.2]
  def change
    create_table :expenditures do |t|
      t.integer :source_category_id
      t.datetime :period
      t.decimal :amount

      t.timestamps null: false
    end
  end
end
