class AddFinalToCostSheet < ActiveRecord::Migration[5.2]
  def change
    add_column :cost_sheets, :final, :boolean
  end
end
