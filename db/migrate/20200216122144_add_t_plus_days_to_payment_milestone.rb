class AddTPlusDaysToPaymentMilestone < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_milestones, :t_plus_days, :integer
  end
end
