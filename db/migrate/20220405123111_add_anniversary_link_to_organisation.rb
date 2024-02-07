class AddAnniversaryLinkToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :anniversary_link, :string
  end
end
