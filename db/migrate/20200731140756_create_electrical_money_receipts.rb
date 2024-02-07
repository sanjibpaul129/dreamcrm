class CreateElectricalMoneyReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :electrical_money_receipts do |t|
      t.integer :flat_id
      t.integer :lead_id
      t.datetime :date
      t.decimal :amount
      t.string :cheque_number
      t.string :bank_name
      t.text :remarks
      t.datetime :mailed_on
      t.datetime :manually_mailed_on

      t.timestamps null: false
    end
  end
end
