class AddRemarksToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :remarks, :text
  end
end
