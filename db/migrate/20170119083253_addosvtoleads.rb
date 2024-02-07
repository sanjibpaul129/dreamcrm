class Addosvtoleads < ActiveRecord::Migration[5.2]
  def change
  	add_column :leads, :osv, :boolean
  end
end
