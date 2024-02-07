class AddSiteVisitedToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :site_visited, :boolean
  end
end
