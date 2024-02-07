class AddSearchingSinceToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :searching_since, :string
  end
end
