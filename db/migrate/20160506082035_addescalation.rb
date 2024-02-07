class Addescalation < ActiveRecord::Migration[5.2]
  def change
  	add_column :personnels, :escalate_in, :integer
  	add_column :leads, :escalated_to, :integer
  	add_column :leads, :escalation_level, :integer
  	add_column :leads, :escalation_time, :datetime
  end
end
