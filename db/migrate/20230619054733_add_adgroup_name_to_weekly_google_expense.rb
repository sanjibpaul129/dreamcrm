class AddAdgroupNameToWeeklyGoogleExpense < ActiveRecord::Migration[5.2]
  def change
    add_column :weekly_google_expenses, :adgroup_name, :string
  end
end
