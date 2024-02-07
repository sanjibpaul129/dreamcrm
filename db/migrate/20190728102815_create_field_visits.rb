class CreateFieldVisits < ActiveRecord::Migration[5.2]
  def change
    create_table :field_visits do |t|
      t.integer :follow_up_id
      t.datetime :date

      t.timestamps null: false
    end
  end
end
