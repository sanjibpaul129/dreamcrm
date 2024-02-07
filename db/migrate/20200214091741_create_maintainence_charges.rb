class CreateMaintainenceCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :maintainence_charges do |t|
      t.decimal :rate
      t.datetime :applicable_from
      t.integer :business_unit_id
      t.integer :company_id

      t.timestamps null: false
    end
  end
end
