class CreateDemandMoneyReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :demand_money_receipts do |t|
      t.integer :booking_id
      t.datetime :date
      t.decimal :amount
      t.string :cheque_number
      t.string :bank_name
      t.text :remarks

      t.timestamps null: false
    end
  end
end
