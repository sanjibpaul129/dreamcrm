class AddVisitOrganisedToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :visit_organised, :boolean
  end
end
