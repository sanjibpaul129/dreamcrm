class CreateExtraCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :extra_charges do |t|
      t.integer :organisation_id
      t.string :description
      t.decimal :service_tax

      t.timestamps
    end
  end
end
