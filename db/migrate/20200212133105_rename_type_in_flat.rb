class RenameTypeInFlat < ActiveRecord::Migration[5.2]
  def change
  	rename_column :flats, :type, :BHK
  end
end
