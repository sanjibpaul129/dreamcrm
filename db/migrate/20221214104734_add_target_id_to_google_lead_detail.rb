class AddTargetIdToGoogleLeadDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :google_lead_details, :target_id, :string
  end
end
