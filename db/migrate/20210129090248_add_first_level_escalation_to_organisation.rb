class AddFirstLevelEscalationToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :first_level_escalation, :integer
  end
end
