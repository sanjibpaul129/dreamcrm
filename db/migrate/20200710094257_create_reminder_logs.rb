class CreateReminderLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :reminder_logs do |t|
      t.integer :flat_id
      t.datetime :sent_on

      t.timestamps null: false
    end
  end
end
