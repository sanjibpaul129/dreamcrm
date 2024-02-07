class AddWorkAreaIdToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :work_area_id, :integer
  end
end
