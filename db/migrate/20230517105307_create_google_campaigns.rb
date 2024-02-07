class CreateGoogleCampaigns < ActiveRecord::Migration[5.2]
  def change
    create_table :google_campaigns do |t|
      t.integer :business_unit_id
      t.string :campaign_id
      t.string :adgroup_id
      t.string :campaign_name
      t.string :adgroup_name

      t.timestamps null: false
    end
  end
end
