class AddAdgroupNameToMonthlyGoogleExpense < ActiveRecord::Migration[5.2]
  def change
    add_column :monthly_google_expenses, :adgroup_name, :string
  end
end
