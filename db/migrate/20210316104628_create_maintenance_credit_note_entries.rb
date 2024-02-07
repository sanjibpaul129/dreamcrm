class CreateMaintenanceCreditNoteEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :maintenance_credit_note_entries do |t|
      t.integer :lead_id
      t.datetime :date
      t.text :remarks
      t.decimal :amount
      t.string :head
      t.text :remarks_to_show

      t.timestamps null: false
    end
  end
end
