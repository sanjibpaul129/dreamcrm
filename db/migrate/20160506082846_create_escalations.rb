class CreateEscalations < ActiveRecord::Migration[5.2]
  def change
    create_table :escalations do |t|
      t.integer :level
      t.integer :personnel_id
      t.integer :year
      t.integer :month
      t.integer :count

      t.timestamps
    end
  end
end
