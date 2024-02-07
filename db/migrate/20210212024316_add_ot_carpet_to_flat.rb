class AddOtCarpetToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :ot_carpet, :decimal
  end
end
