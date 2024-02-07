class CreateElectricalBills < ActiveRecord::Migration[5.2]
  def change
    create_table :electrical_bills do |t|
      t.integer :serial
      t.integer :flat_id
      t.integer :lead_id
      t.datetime :date
      t.datetime :from
      t.datetime :to
      t.decimal :unit
      t.decimal :opening_reading
      t.decimal :closing_reading
      t.decimal :amount
      t.datetime :mailed_on
      t.datetime :manually_mailed_on

      t.timestamps null: false
    end
  end
end
