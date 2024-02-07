class CreateMaintainenceLedgerEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :maintainence_ledger_entries do |t|
      t.integer :lead_id
      t.datetime :date
      t.decimal :amount
      t.integer :maintainence_bill_id
      t.integer :money_receipt_id

      t.timestamps null: false
    end
  end
end
