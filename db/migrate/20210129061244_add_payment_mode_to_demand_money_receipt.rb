class AddPaymentModeToDemandMoneyReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :demand_money_receipts, :payment_mode, :string
  end
end
