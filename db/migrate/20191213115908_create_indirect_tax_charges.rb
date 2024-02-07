class CreateIndirectTaxCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :indirect_tax_charges do |t|
      t.string :name
      t.decimal :rate
      t.integer :business_unit_id
      t.integer :type
      t.datetime :date

      t.timestamps null: false
    end
  end
end
