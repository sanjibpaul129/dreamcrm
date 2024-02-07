class CreateFlatPlcs < ActiveRecord::Migration[5.2]
  def change
    create_table :flat_plcs do |t|
      t.integer :flat_id
      t.integer :plc_charge_id

      t.timestamps
    end
  end
end
