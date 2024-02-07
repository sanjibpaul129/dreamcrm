class CreateTimeBasedMilestones < ActiveRecord::Migration[5.2]
  def change
    create_table :time_based_milestones do |t|
      t.integer :previous_payment_milestone_id
      t.integer :subsequent_payment_milestone_id
      t.integer :days_after

      t.timestamps null: false
    end
  end
end
