class CreateFlcCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :flc_charges do |t|
      t.integer :block_id
      t.integer :rate
      t.integer :from_floor

      t.timestamps
    end
  end
end
