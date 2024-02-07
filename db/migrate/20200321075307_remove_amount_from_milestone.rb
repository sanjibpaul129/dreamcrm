class RemoveAmountFromMilestone < ActiveRecord::Migration[5.2]
  def change
  	add_column :milestones, :amount, :decimal
  end
end
