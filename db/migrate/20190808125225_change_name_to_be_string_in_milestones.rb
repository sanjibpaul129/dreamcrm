class ChangeNameToBeStringInMilestones < ActiveRecord::Migration[5.2]
  def change
  	  change_column :milestones, :name, :string
  end
end
