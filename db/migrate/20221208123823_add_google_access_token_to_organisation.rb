class AddGoogleAccessTokenToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :google_access_token, :text
  end
end
