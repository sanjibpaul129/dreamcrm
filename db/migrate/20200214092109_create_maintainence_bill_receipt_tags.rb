class CreateMaintainenceBillReceiptTags < ActiveRecord::Migration[5.2]
  def change
    create_table :maintainence_bill_receipt_tags do |t|
      t.integer :maintainence_bill_id
      t.integer :money_receipt_id
      t.decimal :amount
      t.integer :month
      t.integer :year

      t.timestamps null: false
    end
  end
end
