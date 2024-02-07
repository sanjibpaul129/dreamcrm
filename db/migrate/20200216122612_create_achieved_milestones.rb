class CreateAchievedMilestones < ActiveRecord::Migration[5.2]
  def change
    create_table :achieved_milestones do |t|
      t.integer :payment_milestone_id
      t.integer :block_id
      t.integer :floor
      t.datetime :date
      t.boolean :demand_raised

      t.timestamps null: false
    end
  end
end
