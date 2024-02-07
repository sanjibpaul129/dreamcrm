class CreateMoneyReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :money_receipts do |t|
      t.integer :lead_id
      t.datetime :date
      t.decimal :amount

      t.timestamps null: false
    end
  end
end
