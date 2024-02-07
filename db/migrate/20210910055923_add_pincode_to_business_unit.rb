class AddPincodeToBusinessUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :business_units, :pincode, :string
  end
end
