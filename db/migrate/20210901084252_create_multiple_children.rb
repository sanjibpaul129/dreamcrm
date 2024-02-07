class CreateMultipleChildren < ActiveRecord::Migration[5.2]
  def change
    create_table :multiple_children do |t|
      t.string :name
      t.datetime :dob
      t.integer :lead_id

      t.timestamps null: false
    end
  end
end
