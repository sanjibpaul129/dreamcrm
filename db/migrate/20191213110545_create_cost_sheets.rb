class CreateCostSheets < ActiveRecord::Migration[5.2]
  def change
    create_table :cost_sheets do |t|
      t.integer :lead_id
      t.integer :payment_plan_id
      t.integer :car_parking_nature_id
      t.integer :number_of_car_parkings
      t.integer :flat_id

      t.timestamps null: false
    end
  end
end
