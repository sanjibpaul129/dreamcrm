class RemoveAmountFromLedgerHeader < ActiveRecord::Migration[5.2]
  def change
    remove_column :ledger_entry_headers, :amount, :decimal
  end
end
