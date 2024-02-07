class AddMappedToPersonnel < ActiveRecord::Migration[5.2]
  def change
    add_column :personnels, :mapped, :integer
  end
end
