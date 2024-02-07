class CreateTaxes < ActiveRecord::Migration[5.2]
  def change
    create_table :taxes do |t|
      t.integer :business_unit_id
      t.string :name
      t.decimal :overall
      t.decimal :car_park
      t.decimal :basic
      t.decimal :plc
      t.decimal :edc
      t.date :applicable_from

      t.timestamps null: false
    end
  end
end
