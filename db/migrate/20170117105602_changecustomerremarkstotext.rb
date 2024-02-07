class Changecustomerremarkstotext < ActiveRecord::Migration[5.2]
  def change
  	change_column :leads, :customer_remarks, :text
  end
end
