class AddPaymentMilestoneIdToMilestone < ActiveRecord::Migration[5.2]
  def change
    add_column :milestones, :payment_milestone_id, :integer
  end
end
