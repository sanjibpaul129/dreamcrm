class AddAbsentToPersonnel < ActiveRecord::Migration[5.2]
  def change
    add_column :personnels, :absent, :boolean
  end
end
