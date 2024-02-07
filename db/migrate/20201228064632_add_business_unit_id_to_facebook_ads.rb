class AddBusinessUnitIdToFacebookAds < ActiveRecord::Migration[5.2]
  def change
    add_column :facebook_ads, :business_unit_id, :integer
  end
end
