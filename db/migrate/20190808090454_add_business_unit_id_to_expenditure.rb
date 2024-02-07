class AddBusinessUnitIdToExpenditure < ActiveRecord::Migration[5.2]
  def change
    add_column :expenditures, :business_unit_id, :integer
  end
end
