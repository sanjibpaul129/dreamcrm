class Addsubfieldsfromleads < ActiveRecord::Migration[5.2]
  def change
	
	add_column :leads, :budget_from, :integer
	add_column :leads, :budget_to, :integer
	remove_column :leads, :budget, :integer
	add_column :leads, :auto_info, :text
  end
end
