class AddOrganisationIdToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :organisation_id, :integer
  end
end
