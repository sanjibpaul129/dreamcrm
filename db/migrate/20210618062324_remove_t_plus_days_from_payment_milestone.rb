class RemoveTPlusDaysFromPaymentMilestone < ActiveRecord::Migration[5.2]
  def change
    remove_column :payment_milestones, :t_plus_days, :integer
  end
end
