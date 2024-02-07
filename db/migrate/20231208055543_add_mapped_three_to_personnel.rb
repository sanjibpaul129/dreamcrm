class AddMappedThreeToPersonnel < ActiveRecord::Migration[5.2]
  def change
    add_column :personnels, :mapped_three, :integer
  end
end
