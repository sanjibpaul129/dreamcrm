class AddBusinessUnitIdToBlockExtraCharge < ActiveRecord::Migration[5.2]
  def change
    add_column :block_extra_charges, :business_unit_id, :integer
  end
end
