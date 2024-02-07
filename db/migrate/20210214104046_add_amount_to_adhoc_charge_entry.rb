class AddAmountToAdhocChargeEntry < ActiveRecord::Migration[5.2]
  def change
    add_column :adhoc_charge_entries, :amount, :decimal
  end
end
