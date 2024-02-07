class RenameExtraChargePercentageInMilestone < ActiveRecord::Migration[5.2]
  def change
  	rename_column :milestones, :extra_charge_percentage, :extra_development_charge_percentage
  end
end
