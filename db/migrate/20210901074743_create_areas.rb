class CreateAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :areas do |t|
      t.string :name
      t.integer :organisation_id

      t.timestamps null: false
    end
  end
end
