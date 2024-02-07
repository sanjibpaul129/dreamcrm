class AddApiKeyToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :api_key, :string
  end
end
