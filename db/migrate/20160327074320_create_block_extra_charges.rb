class CreateBlockExtraCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :block_extra_charges do |t|
      t.integer :block_id
      t.integer :extra_charge_id
      t.decimal :percentage
      t.integer :amount
      t.decimal :rate
      t.integer :flat_type

      t.timestamps
    end
  end
end
