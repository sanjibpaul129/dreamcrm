class AddInstrumentDateToDemandMoneyReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :demand_money_receipts, :instrument_date, :datetime
  end
end
