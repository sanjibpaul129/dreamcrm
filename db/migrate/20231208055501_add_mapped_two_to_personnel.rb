class AddMappedTwoToPersonnel < ActiveRecord::Migration[5.2]
  def change
    add_column :personnels, :mapped_two, :integer
  end
end
