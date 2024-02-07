class AddAreaToBusinessUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :business_units, :area, :string
  end
end
