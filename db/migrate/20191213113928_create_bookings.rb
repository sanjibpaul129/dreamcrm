class CreateBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings do |t|
      t.integer :cost_sheet_id
      t.integer :personnel_id
      t.datetime :date
      t.datetime :allotment_date
      t.datetime :agreement_date
      t.datetime :posession_date
      t.datetime :reqistration_date
      t.datetime :cancellation_date

      t.timestamps null: false
    end
  end
end
