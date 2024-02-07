class AddNetworkToGoogleLeadDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :google_lead_details, :network, :string
    add_column :google_lead_details, :campaignid, :string
    add_column :google_lead_details, :adgroupid, :string
    add_column :google_lead_details, :gclid, :string
    add_column :google_lead_details, :target, :string
    add_column :google_lead_details, :placement, :string
    add_column :google_lead_details, :creative, :string
    add_column :google_lead_details, :adposition, :string
    add_column :google_lead_details, :keyword, :string
  end
end
