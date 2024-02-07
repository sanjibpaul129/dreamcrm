class AddOrganisedVisitToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :organised_visit, :boolean
  end
end
