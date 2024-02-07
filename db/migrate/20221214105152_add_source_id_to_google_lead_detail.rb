class AddSourceIdToGoogleLeadDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :google_lead_details, :source_id, :string
  end
end
