class CreateCarParkNatures < ActiveRecord::Migration[5.2]
  def change
    create_table :car_park_natures do |t|
      t.integer :wheels
      t.string :description

      t.timestamps
    end
  end
end
