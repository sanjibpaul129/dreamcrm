class AddMatchTypeToGoogleLeadDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :google_lead_details, :match_type, :string
  end
end
