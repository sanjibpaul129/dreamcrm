class AddOrganisationIdToBulkRecipient < ActiveRecord::Migration[5.2]
  def change
    add_column :bulk_recipients, :organisation_id, :integer
  end
end
