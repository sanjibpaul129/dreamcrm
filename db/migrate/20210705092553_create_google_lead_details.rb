class CreateGoogleLeadDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :google_lead_details do |t|
      t.integer :lead_id
      t.string :utm_source
      t.string :utm_campaign
      t.string :utm_medium
      t.string :utm_content
      t.string :utm_term
      t.string :communicated_through

      t.timestamps null: false
    end
  end
end
