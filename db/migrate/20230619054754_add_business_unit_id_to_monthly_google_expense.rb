class AddBusinessUnitIdToMonthlyGoogleExpense < ActiveRecord::Migration[5.2]
  def change
    add_column :monthly_google_expenses, :business_unit_id, :integer
  end
end
