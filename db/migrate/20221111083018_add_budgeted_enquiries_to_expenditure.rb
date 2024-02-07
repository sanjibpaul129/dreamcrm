class AddBudgetedEnquiriesToExpenditure < ActiveRecord::Migration[5.2]
  def change
    add_column :expenditures, :budgeted_enquiries, :integer
  end
end
