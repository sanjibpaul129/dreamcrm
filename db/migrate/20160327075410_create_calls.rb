class CreateCalls < ActiveRecord::Migration[5.2]
  def change
    create_table :calls do |t|
      t.integer :marketing_number_id
      t.string :number_id
      t.string :number
      t.datetime :start_time
      t.datetime :end_time
      t.integer :personnels_id
      t.boolean :nature

      t.timestamps
    end
  end
end
