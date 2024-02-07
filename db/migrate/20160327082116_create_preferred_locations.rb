class CreatePreferredLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :preferred_locations do |t|
      t.string :description
      t.integer :organisation_id

      t.timestamps
    end
  end
end
