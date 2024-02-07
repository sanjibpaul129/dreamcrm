class CreateFacebookAds < ActiveRecord::Migration[5.2]
  def change
    create_table :facebook_ads do |t|
      t.string :campaign_id
      t.string :adset_id
      t.string :ad_id
      t.string :form_id
      t.integer :source_category_id

      t.timestamps null: false
    end
  end
end
