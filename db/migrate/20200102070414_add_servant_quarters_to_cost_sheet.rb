class AddServantQuartersToCostSheet < ActiveRecord::Migration[5.2]
  def change
    add_column :cost_sheets, :servant_quarters, :integer
  end
end
