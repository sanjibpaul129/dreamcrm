class CreateBrokers < ActiveRecord::Migration[5.2]
  def change
    create_table :brokers do |t|
      t.string :name
      t.text :address
      t.boolean :firm
      t.boolean :premium
      t.integer :personnel_id

      t.timestamps null: false
    end
  end
end
