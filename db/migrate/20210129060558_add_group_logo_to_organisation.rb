class AddGroupLogoToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :group_logo, :string
  end
end
