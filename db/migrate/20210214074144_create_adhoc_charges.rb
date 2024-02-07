class CreateAdhocCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :adhoc_charges do |t|
      t.string :description
      t.integer :organisation_id

      t.timestamps null: false
    end
  end
end
