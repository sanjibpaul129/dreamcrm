class AddConfirmedToCostSheet < ActiveRecord::Migration[5.2]
  def change
    add_column :cost_sheets, :confirmed, :boolean
  end
end
