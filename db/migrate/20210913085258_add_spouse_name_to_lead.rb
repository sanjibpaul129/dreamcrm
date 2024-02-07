class AddSpouseNameToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :spouse_name, :string
  end
end
