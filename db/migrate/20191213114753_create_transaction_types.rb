class CreateTransactionTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :transaction_types do |t|
      t.string :name
      t.integer :organisation_id
      t.boolean :nature

      t.timestamps null: false
    end
  end
end
