class AddPriceToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :price, :decimal
  end
end
