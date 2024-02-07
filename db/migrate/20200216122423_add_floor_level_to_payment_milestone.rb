class AddFloorLevelToPaymentMilestone < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_milestones, :floor_level, :boolean
  end
end
