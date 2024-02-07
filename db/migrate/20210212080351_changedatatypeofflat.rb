class Changedatatypeofflat < ActiveRecord::Migration[5.2]
  def change
  	change_column :flats, :flat_bua, :decimal
  	change_column :flats, :OTA, :decimal
  end
end
