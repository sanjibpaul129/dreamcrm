class AddCityToBusinessUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :business_units, :city, :string
  end
end
