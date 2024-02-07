class CreateCreditNoteEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :credit_note_entries do |t|
      t.integer :booking_id
      t.integer :credit_note_head_id
      t.datetime :date
      t.text :remarks

      t.timestamps null: false
    end
  end
end
