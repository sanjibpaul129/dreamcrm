class DropBlockExtraCharge < ActiveRecord::Migration[5.2]
  def change
  	drop_table :block_extra_charges
  end
end
