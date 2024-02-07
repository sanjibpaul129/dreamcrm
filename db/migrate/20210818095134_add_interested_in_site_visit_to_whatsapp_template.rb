class AddInterestedInSiteVisitToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :interested_in_site_visit, :boolean
  end
end
