class AddOrganisationIdToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :organisation_id, :integer
  end
end
