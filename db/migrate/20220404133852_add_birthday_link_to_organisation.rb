class AddBirthdayLinkToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :birthday_link, :string
  end
end
