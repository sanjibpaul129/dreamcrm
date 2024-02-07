class AddPlatformToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :platform, :string
  end
end
