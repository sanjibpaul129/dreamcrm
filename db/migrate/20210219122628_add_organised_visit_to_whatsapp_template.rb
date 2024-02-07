class AddOrganisedVisitToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :organised_visit, :boolean
  end
end
