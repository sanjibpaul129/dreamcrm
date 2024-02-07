class CreateCallRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :call_records do |t|
      t.string :contact_name
      t.datetime :occurred_at
      t.string :number
      t.integer :call_length
      t.integer :status
      t.string :caller
      t.integer :organisation_id

      t.timestamps null: false
    end
  end
end
