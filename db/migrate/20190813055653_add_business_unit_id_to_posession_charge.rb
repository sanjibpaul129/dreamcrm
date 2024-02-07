class AddBusinessUnitIdToPosessionCharge < ActiveRecord::Migration[5.2]
  def change
    add_column :posession_charges, :business_unit_id, :integer
  end
end
