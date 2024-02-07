class AddIfscCodeToBusinessUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :business_units, :ifsc_code, :string
  end
end
