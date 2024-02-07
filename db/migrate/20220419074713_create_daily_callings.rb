class CreateDailyCallings < ActiveRecord::Migration[5.2]
  def change
    create_table :daily_callings do |t|
      t.integer :personnel_id
      t.integer :lead_id
      t.datetime :date
      t.decimal :duration
      t.string :called_number

      t.timestamps null: false
    end
  end
end
