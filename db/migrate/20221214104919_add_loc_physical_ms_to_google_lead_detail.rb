class AddLocPhysicalMsToGoogleLeadDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :google_lead_details, :loc_physical_ms, :string
  end
end
