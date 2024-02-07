class AddRemarksToExpenditure < ActiveRecord::Migration[5.2]
  def change
    add_column :expenditures, :remarks, :text
  end
end
