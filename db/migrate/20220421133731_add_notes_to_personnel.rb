class AddNotesToPersonnel < ActiveRecord::Migration[5.2]
  def change
    add_column :personnels, :notes, :text
  end
end
