class CreateLedgerEntryHeaders < ActiveRecord::Migration[5.2]
  def change
    create_table :ledger_entry_headers do |t|
      t.integer :booking_id
      t.datetime :date
      t.integer :transaction_type_id
      t.decimal :amount
      t.integer :ledger_entry_header_tag

      t.timestamps null: false
    end
  end
end
