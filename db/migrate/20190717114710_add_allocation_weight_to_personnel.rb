class AddAllocationWeightToPersonnel < ActiveRecord::Migration[5.2]
  def change
    add_column :personnels, :allocation_weight, :decimal
  end
end
