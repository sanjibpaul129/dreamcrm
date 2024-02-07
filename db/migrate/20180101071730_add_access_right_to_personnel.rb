class AddAccessRightToPersonnel < ActiveRecord::Migration[5.2]
  def change
  	add_column :personnels, :access_right, :integer
  end
end
