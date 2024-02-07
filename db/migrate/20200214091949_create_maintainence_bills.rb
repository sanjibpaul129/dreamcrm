class CreateMaintainenceBills < ActiveRecord::Migration[5.2]
  def change
    create_table :maintainence_bills do |t|
      t.integer :serial
      t.integer :lead_id
      t.datetime :from
      t.datetime :to
      t.datetime :date

      t.timestamps null: false
    end
  end
end
