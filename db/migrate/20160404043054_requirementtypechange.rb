class Requirementtypechange < ActiveRecord::Migration[5.2]
  def change
  	remove_column :leads, :requirement, :string
  	add_column :leads, :requirement, :integer
  end
end
