class AddOrganisationIdToOtherProject < ActiveRecord::Migration[5.2]
  def change
    add_column :other_projects, :organisation_id, :integer
  end
end
