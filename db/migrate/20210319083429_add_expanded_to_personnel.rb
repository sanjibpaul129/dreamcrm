class AddExpandedToPersonnel < ActiveRecord::Migration[5.2]
  def change
    add_column :personnels, :expanded, :boolean
  end
end
