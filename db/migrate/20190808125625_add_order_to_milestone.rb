class AddOrderToMilestone < ActiveRecord::Migration[5.2]
  def change
    add_column :milestones, :order, :integer
  end
end
