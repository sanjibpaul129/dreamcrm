class AddTPlusPaymentMilestoneIdToPaymentMilestone < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_milestones, :t_plus_payment_milestone_id, :integer
  end
end
