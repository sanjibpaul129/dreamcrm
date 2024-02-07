class CreateLedgerEntryItems < ActiveRecord::Migration[5.2]
  def change
    create_table :ledger_entry_items do |t|
      t.integer :ledger_entry_header_id
      t.integer :milestone_id

      t.timestamps null: false
    end
  end
end
