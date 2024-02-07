class RemoveRoundRobinFromPersonnel < ActiveRecord::Migration[5.2]
  def change
    remove_column :personnels, :round_robin, :boolean
  end
end
