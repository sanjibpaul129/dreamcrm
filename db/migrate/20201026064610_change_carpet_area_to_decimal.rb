class ChangeCarpetAreaToDecimal < ActiveRecord::Migration[5.2]
  def change
  	change_column :flats, :carpet_area, :decimal
  end
end
