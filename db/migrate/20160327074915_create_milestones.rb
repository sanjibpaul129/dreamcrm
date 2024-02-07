class CreateMilestones < ActiveRecord::Migration[5.2]
  def change
    create_table :milestones do |t|
      t.integer :name
      t.decimal :flat_value_percentage
      t.decimal :extra_charge_percentage
      t.integer :extra_charge_id
      t.boolean :nature
      t.integer :payment_plan_id

      t.timestamps
    end
  end
end
