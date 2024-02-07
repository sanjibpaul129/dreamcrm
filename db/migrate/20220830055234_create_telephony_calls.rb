class CreateTelephonyCalls < ActiveRecord::Migration[5.2]
  def change
    create_table :telephony_calls do |t|
      t.decimal :duration
      t.string :recording_url
      t.string :k_number
      t.datetime :start_time
      t.string :call_type
      t.string :call_outcome

      t.timestamps null: false
    end
  end
end
