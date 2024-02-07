class AddTypeToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :type, :string
  end
end
