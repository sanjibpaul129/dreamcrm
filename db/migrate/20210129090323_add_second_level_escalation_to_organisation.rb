class AddSecondLevelEscalationToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :second_level_escalation, :integer
  end
end
