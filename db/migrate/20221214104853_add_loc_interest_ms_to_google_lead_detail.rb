class AddLocInterestMsToGoogleLeadDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :google_lead_details, :loc_interest_ms, :string
  end
end
