class AddFamilySizeToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :family_size, :string
  end
end
