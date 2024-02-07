class CreateMaintenanceBillSerials < ActiveRecord::Migration[5.2]
  def change
    create_table :maintenance_bill_serials do |t|
      t.integer :last

      t.timestamps null: false
    end
  end
end
