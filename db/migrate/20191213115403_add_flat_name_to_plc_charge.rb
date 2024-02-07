class AddFlatNameToPlcCharge < ActiveRecord::Migration[5.2]
  def change
    add_column :plc_charges, :flat_name, :string
  end
end
