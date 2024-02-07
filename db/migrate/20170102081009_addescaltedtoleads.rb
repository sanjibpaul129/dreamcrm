class Addescaltedtoleads < ActiveRecord::Migration[5.2]
  def change
  	add_column :leads, :escalated, :boolean
  end
end
