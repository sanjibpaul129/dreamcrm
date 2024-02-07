class AddFbclidToGoogleLeadDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :google_lead_details, :fbclid, :string
  end
end
