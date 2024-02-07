class AddViewOnlyToPersonnel < ActiveRecord::Migration[5.2]
  def change
    add_column :personnels, :view_only, :boolean
  end
end
