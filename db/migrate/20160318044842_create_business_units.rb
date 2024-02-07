class CreateBusinessUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :business_units do |t|
      t.string :name
      t.integer :organisation_id
      t.integer :company_id
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :address_4
      t.string :email
      t.string :shortform
      t.string :logo

      t.timestamps
    end
  end
end
