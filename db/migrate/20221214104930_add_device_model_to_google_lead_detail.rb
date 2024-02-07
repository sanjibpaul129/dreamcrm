class AddDeviceModelToGoogleLeadDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :google_lead_details, :device_model, :string
  end
end
