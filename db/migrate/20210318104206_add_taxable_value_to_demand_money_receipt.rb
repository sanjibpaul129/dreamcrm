class AddTaxableValueToDemandMoneyReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :demand_money_receipts, :taxable_value, :decimal
  end
end
