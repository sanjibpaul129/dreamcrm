class AddExtentionIdToGoogleLeadDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :google_lead_details, :extention_id, :string
  end
end
