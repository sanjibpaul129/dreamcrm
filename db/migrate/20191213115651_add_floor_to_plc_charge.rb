class AddFloorToPlcCharge < ActiveRecord::Migration[5.2]
  def change
    add_column :plc_charges, :floor, :integer
  end
end
