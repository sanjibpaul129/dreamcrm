class RemovePlatformFromFacebookAd < ActiveRecord::Migration[5.2]
  def change
    remove_column :facebook_ads, :platform, :string
  end
end
