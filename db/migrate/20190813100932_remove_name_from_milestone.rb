class RemoveNameFromMilestone < ActiveRecord::Migration[5.2]
  def change
    remove_column :milestones, :name, :string
  end
end
