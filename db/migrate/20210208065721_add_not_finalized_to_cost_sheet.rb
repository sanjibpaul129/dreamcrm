class AddNotFinalizedToCostSheet < ActiveRecord::Migration[5.2]
  def change
    add_column :cost_sheets, :not_finalized, :boolean
  end
end
