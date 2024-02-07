class AddAmountToMilestone < ActiveRecord::Migration[5.2]
  def change
    remove_column :milestones, :amount
  end
end
