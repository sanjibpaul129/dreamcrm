class CreateAccessPointPersonnels < ActiveRecord::Migration[5.2]
  def change
    create_table :access_point_personnels do |t|
      t.integer :access_point_id
      t.integer :personnel_id

      t.timestamps null: false
    end
  end
end
