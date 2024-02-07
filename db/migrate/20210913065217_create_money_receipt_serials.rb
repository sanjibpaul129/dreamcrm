class CreateMoneyReceiptSerials < ActiveRecord::Migration[5.2]
  def change
    create_table :money_receipt_serials do |t|
      t.integer :business_unit_id
      t.integer :serial
      t.integer :year_end

      t.timestamps null: false
    end
  end
end
