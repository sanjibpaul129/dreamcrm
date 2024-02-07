class AddLastRobinToPersonnel < ActiveRecord::Migration[5.2]
  def change
    add_column :personnels, :last_robin, :boolean
  end
end
