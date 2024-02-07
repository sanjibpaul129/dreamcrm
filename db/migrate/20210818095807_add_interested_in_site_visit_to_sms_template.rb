class AddInterestedInSiteVisitToSmsTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :sms_templates, :interested_in_site_visit, :boolean
  end
end
