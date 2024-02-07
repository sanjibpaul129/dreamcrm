class AddRoundRobinToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :round_robin, :boolean
  end
end
