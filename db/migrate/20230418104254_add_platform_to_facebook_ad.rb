class AddPlatformToFacebookAd < ActiveRecord::Migration[5.2]
  def change
    add_column :facebook_ads, :platform, :string
  end
end
