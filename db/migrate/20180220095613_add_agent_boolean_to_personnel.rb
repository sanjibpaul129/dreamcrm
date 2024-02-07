class AddAgentBooleanToPersonnel < ActiveRecord::Migration[5.2]
  def change
  	add_column :personnels, :agent, :boolean
  end
end
