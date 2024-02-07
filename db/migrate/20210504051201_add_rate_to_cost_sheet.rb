class AddRateToCostSheet < ActiveRecord::Migration[5.2]
  def change
    add_column :cost_sheets, :rate, :decimal
  end
end
