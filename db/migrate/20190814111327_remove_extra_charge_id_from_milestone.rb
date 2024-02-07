class RemoveExtraChargeIdFromMilestone < ActiveRecord::Migration[5.2]
  def change
    remove_column :milestones, :extra_charge_id, :integer
  end
end
