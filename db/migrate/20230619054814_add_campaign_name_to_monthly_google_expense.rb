class AddCampaignNameToMonthlyGoogleExpense < ActiveRecord::Migration[5.2]
  def change
    add_column :monthly_google_expenses, :campaign_name, :string
  end
end
