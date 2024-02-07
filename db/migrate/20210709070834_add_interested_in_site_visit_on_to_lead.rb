class AddInterestedInSiteVisitOnToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :interested_in_site_visit_on, :datetime
  end
end
