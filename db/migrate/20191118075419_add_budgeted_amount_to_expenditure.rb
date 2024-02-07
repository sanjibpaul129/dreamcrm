class AddBudgetedAmountToExpenditure < ActiveRecord::Migration[5.2]
  def change
    add_column :expenditures, :budgeted_amount, :decimal
  end
end
