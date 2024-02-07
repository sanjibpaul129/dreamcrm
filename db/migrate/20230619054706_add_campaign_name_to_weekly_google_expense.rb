class AddCampaignNameToWeeklyGoogleExpense < ActiveRecord::Migration[5.2]
  def change
    add_column :weekly_google_expenses, :campaign_name, :string
  end
end
