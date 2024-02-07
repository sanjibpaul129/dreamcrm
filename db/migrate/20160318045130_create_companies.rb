class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.string :name
      t.integer :organisation_id
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :address_4
      t.string :phone

      t.timestamps
    end
  end
end
