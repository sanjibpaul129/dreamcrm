class AddSiteExecutiveRatingToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :site_executive_rating, :integer
  end
end
