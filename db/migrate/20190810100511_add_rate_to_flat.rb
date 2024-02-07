class AddRateToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :rate, :decimal
  end
end
