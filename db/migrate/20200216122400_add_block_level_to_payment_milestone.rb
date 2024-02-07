class AddBlockLevelToPaymentMilestone < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_milestones, :block_level, :boolean
  end
end
