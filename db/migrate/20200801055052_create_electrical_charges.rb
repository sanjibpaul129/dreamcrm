class CreateElectricalCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :electrical_charges do |t|
      t.integer :company_id
      t.integer :business_unit_id
      t.datetime :applicable_from
      t.decimal :rate

      t.timestamps null: false
    end
  end
end
