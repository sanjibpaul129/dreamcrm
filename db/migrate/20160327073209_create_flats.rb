class CreateFlats < ActiveRecord::Migration[5.2]
  def change
    create_table :flats do |t|
      t.integer :block_id
      t.integer :floor
      t.string :name
      t.boolean :status
      t.integer :SBA
      t.integer :OTA
      t.decimal :flat_bua
      t.decimal :ot_bua
      t.decimal :flat_bua_markup
      t.decimal :ot_bua_markdown
      t.integer :bathrooms
      t.integer :balconies

      t.timestamps
    end
  end
end
