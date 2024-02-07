class CreateExtraDevelopmentCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :extra_development_charges do |t|
      t.integer :business_unit_id
      t.integer :extra_charge_id
      t.integer :block_id
      t.integer :percentage
      t.decimal :amount
      t.decimal :rate
      t.string :flat_type

      t.timestamps null: false
    end
  end
end
