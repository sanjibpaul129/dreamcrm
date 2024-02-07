class CreateWishToCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :wish_to_customers do |t|
      t.string :name
      t.string :email
      t.string :mobile
      t.datetime :dob
      t.datetime :doa
      t.string :field_one
      t.string :field_two
      t.string :field_three
      t.integer :organisation_id

      t.timestamps null: false
    end
  end
end
